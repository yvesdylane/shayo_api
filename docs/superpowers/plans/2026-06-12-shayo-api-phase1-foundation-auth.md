# Shayo API — Phase 1: Foundation & Auth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task.

**Goal:** Establish the NestJS application foundation (PrismaModule, shared guards/decorators) and implement all 8 auth endpoints.

**Architecture:** Feature-based modules. PrismaModule is global and shared across all modules. AuthModule handles registration, login, email/phone verification, password reset, and profile management. JWT-based auth with role-based guards.

**Tech Stack:** NestJS 11, Prisma 7, PostgreSQL 16, JWT (passport-jwt), bcrypt, class-validator/class-transformer

---

## File Structure

```
src/
  prisma/
    prisma.module.ts          — Global PrismaModule (@Global)
    prisma.service.ts         — Extends PrismaClient, handles lifecycle
  common/
    guards/
      jwt-auth.guard.ts       — Validates JWT, attaches user to request
      roles.guard.ts          — Checks user roles (admin, restaurant_admin, branch_admin)
    decorators/
      current-user.decorator.ts  — Extracts user from request
      roles.decorator.ts         — Sets required roles metadata
    dto/
      pagination.dto.ts       — Shared pagination query params
  auth/
    auth.module.ts
    auth.controller.ts        — All /auth/* endpoints
    auth.service.ts           — Business logic
    strategies/
      jwt.strategy.ts         — Passport JWT strategy
    dto/
      register.dto.ts
      login.dto.ts
      verify-code.dto.ts
      forgot-password.dto.ts
      reset-password.dto.ts
      update-profile.dto.ts
  users/
    users.module.ts
    users.service.ts          — User CRUD (used by auth and admin)
```

---

## Task 1: Install dependencies

**Files:**
- Modify: `package.json`

- [ ] **Step 1: Install auth & validation packages**

```bash
pnpm add @nestjs/jwt @nestjs/passport passport passport-jwt bcrypt class-validator class-transformer
pnpm add -D @types/passport-jwt @types/bcrypt
```

Expected: All packages added to `package.json`.

- [ ] **Step 2: Verify install**

```bash
pnpm ls @nestjs/jwt @nestjs/passport passport passport-jwt bcrypt class-validator class-transformer
```

Expected: All packages listed.

---

## Task 2: Create PrismaModule (shared database service)

**Files:**
- Create: `src/prisma/prisma.service.ts`
- Create: `src/prisma/prisma.module.ts`

- [ ] **Step 1: Write tests**

```ts
// src/prisma/prisma.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaService } from './prisma.service';

describe('PrismaService', () => {
  let service: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    service = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should be connected (onModuleInit does not throw)', async () => {
    await expect(service.onModuleInit()).resolves.not.toThrow();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pnpm test -- --testPathPattern="prisma" -t "should be defined"`
Expected: FAIL — PrismaService not found.

- [ ] **Step 3: Implement PrismaService**

```ts
// src/prisma/prisma.service.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
  }
}
```

- [ ] **Step 4: Implement PrismaModule**

```ts
// src/prisma/prisma.module.ts
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

- [ ] **Step 5: Add PrismaModule to AppModule imports**

```ts
// src/app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

- [ ] **Step 6: Run tests**

Run: `pnpm test -- --testPathPattern="prisma"`
Expected: PASS

---

## Task 3: Create shared guards, decorators, and DTOs

**Files:**
- Create: `src/common/decorators/current-user.decorator.ts`
- Create: `src/common/decorators/roles.decorator.ts`
- Create: `src/common/guards/jwt-auth.guard.ts`
- Create: `src/common/guards/roles.guard.ts`
- Create: `src/common/dto/pagination.dto.ts`
- Create: `src/auth/strategies/jwt.strategy.ts`

- [ ] **Step 1: Write CurrentUser decorator**

```ts
// src/common/decorators/current-user.decorator.ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;
    return data ? user?.[data] : user;
  },
);
```

- [ ] **Step 2: Write Roles decorator**

```ts
// src/common/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
```

- [ ] **Step 3: Write JwtAuthGuard**

```ts
// src/common/guards/jwt-auth.guard.ts
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
```

- [ ] **Step 4: Write RolesGuard**

```ts
// src/common/guards/roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles || requiredRoles.length === 0) return true;

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.role === role);
  }
}
```

- [ ] **Step 5: Write JwtStrategy**

```ts
// src/auth/strategies/jwt.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'shayo-secret-key',
    });
  }

  async validate(payload: { sub: string; email: string; role: string }) {
    return { id: payload.sub, email: payload.email, role: payload.role };
  }
}
```

- [ ] **Step 6: Write PaginationDto**

```ts
// src/common/dto/pagination.dto.ts
import { IsOptional, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class PaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 10;
}
```

---

## Task 4: Create AuthModule — register & login

**Files:**
- Create: `src/auth/dto/register.dto.ts`
- Create: `src/auth/dto/login.dto.ts`
- Create: `src/auth/auth.service.ts`
- Create: `src/auth/auth.controller.ts`
- Create: `src/auth/auth.module.ts`
- Create: `src/users/users.service.ts`
- Create: `src/users/users.module.ts`

- [ ] **Step 1: Update AppModule to add validation pipe in main.ts**

```ts
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
```

- [ ] **Step 2: Write RegisterDto**

```ts
// src/auth/dto/register.dto.ts
import { IsEmail, IsString, MinLength, MaxLength, IsOptional } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(3)
  @MaxLength(50)
  userName!: string;

  @IsString()
  @MinLength(6)
  password!: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  firstName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  surName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;
}
```

- [ ] **Step 3: Write LoginDto**

```ts
// src/auth/dto/login.dto.ts
import { IsString, MinLength } from 'class-validator';

export class LoginDto {
  @IsString()
  email!: string;

  @IsString()
  @MinLength(6)
  password!: string;
}
```

- [ ] **Step 4: Create UsersService**

```ts
// src/users/users.service.ts
import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async findByUserName(userName: string) {
    return this.prisma.user.findUnique({ where: { userName } });
  }

  async findById(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async create(data: { email: string; userName: string; password: string; firstName?: string; surName?: string; phone?: string }) {
    const existingEmail = await this.findByEmail(data.email);
    if (existingEmail) throw new ConflictException('Email already registered');

    const existingUserName = await this.findByUserName(data.userName);
    if (existingUserName) throw new ConflictException('Username already taken');

    const hashed = await bcrypt.hash(data.password, 10);
    return this.prisma.user.create({
      data: {
        email: data.email,
        userName: data.userName,
        password: hashed,
        firstName: data.firstName,
        surName: data.surName,
        phone: data.phone,
        wallet: { create: {} },
      },
      select: { id: true, email: true, userName: true, firstName: true, surName: true, phone: true, createdAt: true },
    });
  }

  async update(id: string, data: Record<string, unknown>) {
    return this.prisma.user.update({
      where: { id },
      data,
      select: { id: true, email: true, userName: true, firstName: true, surName: true, phone: true, bio: true, image: true, region: true },
    });
  }
}
```

- [ ] **Step 5: Create UsersModule**

```ts
// src/users/users.module.ts
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';

@Module({
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
```

- [ ] **Step 6: Create AuthService**

```ts
// src/auth/auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(dto: { email: string; userName: string; password: string; firstName?: string; surName?: string; phone?: string }) {
    const user = await this.usersService.create(dto);
    const code = randomBytes(3).toString('hex').toUpperCase().slice(0, 6);
    await this.usersService.update(user.id, { code, codeExpireAt: new Date(Date.now() + 15 * 60 * 1000) });
    // TODO: Send code via email/SMS
    return { user, message: 'Registration successful. Check email/phone for verification code.' };
  }

  async login(dto: { email: string; password: string }) {
    const user = await this.usersService.findByEmail(dto.email);
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const valid = await bcrypt.compare(dto.password, user.password);
    if (!valid) throw new UnauthorizedException('Invalid credentials');

    const payload = { sub: user.id, email: user.email, role: 'user' };
    return { accessToken: this.jwtService.sign(payload), user: { id: user.id, email: user.email, userName: user.userName } };
  }

  async verifyCode(dto: { email: string; code: string }) {
    const user = await this.usersService.findByEmail(dto.email);
    if (!user) throw new UnauthorizedException('User not found');
    if (user.isVerified) return { message: 'Already verified' };
    if (!user.code || user.code !== dto.code) throw new UnauthorizedException('Invalid code');
    if (user.codeExpireAt && user.codeExpireAt < new Date()) throw new UnauthorizedException('Code expired');

    await this.usersService.update(user.id, { isVerified: true, code: null, codeExpireAt: null, verifiedAt: new Date() });
    return { message: 'Verification successful' };
  }

  async resendCode(dto: { email: string }) {
    const user = await this.usersService.findByEmail(dto.email);
    if (!user) throw new UnauthorizedException('User not found');
    if (user.isVerified) return { message: 'Already verified' };

    const code = randomBytes(3).toString('hex').toUpperCase().slice(0, 6);
    await this.usersService.update(user.id, { code, codeExpireAt: new Date(Date.now() + 15 * 60 * 1000) });
    // TODO: Send code via email/SMS
    return { message: 'Code resent' };
  }

  async forgotPassword(dto: { email: string }) {
    const user = await this.usersService.findByEmail(dto.email);
    if (!user) return { message: 'If the email exists, a reset link has been sent.' };

    const token = randomBytes(32).toString('hex');
    await this.usersService.update(user.id, { code: token, codeExpireAt: new Date(Date.now() + 60 * 60 * 1000) });
    // TODO: Send reset link via email
    return { message: 'If the email exists, a reset link has been sent.' };
  }

  async resetPassword(dto: { email: string; code: string; password: string }) {
    const user = await this.usersService.findByEmail(dto.email);
    if (!user) throw new UnauthorizedException('Invalid request');
    if (!user.code || user.code !== dto.code) throw new UnauthorizedException('Invalid token');
    if (user.codeExpireAt && user.codeExpireAt < new Date()) throw new UnauthorizedException('Token expired');

    const hashed = await bcrypt.hash(dto.password, 10);
    await this.usersService.update(user.id, { password: hashed, code: null, codeExpireAt: null });
    return { message: 'Password reset successful' };
  }
}
```

- [ ] **Step 7: Create AuthController**

```ts
// src/auth/auth.controller.ts
import { Controller, Post, Get, Patch, Body, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('verify')
  verifyCode(@Body() dto: { email: string; code: string }) {
    return this.authService.verifyCode(dto);
  }

  @Post('resend-code')
  resendCode(@Body() dto: { email: string }) {
    return this.authService.resendCode(dto);
  }

  @Post('forgot-password')
  forgotPassword(@Body() dto: { email: string }) {
    return this.authService.forgotPassword(dto);
  }

  @Post('reset-password')
  resetPassword(@Body() dto: { email: string; code: string; password: string }) {
    return this.authService.resetPassword(dto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getProfile(@CurrentUser('id') userId: string) {
    return this.authService.getProfile(userId);
  }

  @UseGuards(JwtAuthGuard)
  @Patch('me')
  updateProfile(@CurrentUser('id') userId: string, @Body() dto: Record<string, unknown>) {
    return this.authService.updateProfile(userId, dto);
  }
}
```

- [ ] **Step 8: Create AuthModule**

```ts
// src/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'shayo-secret-key',
      signOptions: { expiresIn: '7d' },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

- [ ] **Step 9: Add JWT_SECRET to .env.example**

```
JWT_SECRET=your-super-secret-key-change-in-production
```

- [ ] **Step 10: Build and check for errors**

Run: `pnpm build`
Expected: Build succeeds with no errors.

---

## Task 5: Add `getProfile` and `updateProfile` to AuthService

**Files:**
- Modify: `src/auth/auth.service.ts`

- [ ] **Step 1: Add methods to AuthService**

```ts
// Add to src/auth/auth.service.ts
async getProfile(userId: string) {
  return this.usersService.findById(userId);
}

async updateProfile(userId: string, data: Record<string, unknown>) {
  const allowedFields = ['firstName', 'surName', 'bio', 'region', 'image'];
  const sanitized: Record<string, unknown> = {};
  for (const key of allowedFields) {
    if (data[key] !== undefined) sanitized[key] = data[key];
  }
  return this.usersService.update(userId, sanitized);
}
```

- [ ] **Step 2: Add update-profile.dto.ts**

```ts
// src/auth/dto/update-profile.dto.ts
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MaxLength(50)
  firstName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  surName?: string;

  @IsOptional()
  @IsString()
  bio?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  region?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  image?: string;
}
```

- [ ] **Step 3: Wire UpdateProfileDto into controller**

```ts
// Update auth.controller.ts
@UseGuards(JwtAuthGuard)
@Patch('me')
updateProfile(@CurrentUser('id') userId: string, @Body() dto: UpdateProfileDto) {
  return this.authService.updateProfile(userId, dto);
}
```

- [ ] **Step 4: Build**

Run: `pnpm build`
Expected: Build succeeds.

---

## Task 6: E2E tests for Auth

**Files:**
- Create: `test/auth.e2e-spec.ts`

- [ ] **Step 1: Write e2e test**

```ts
// test/auth.e2e-spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Auth (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  const testUser = {
    email: `test-${Date.now()}@example.com`,
    userName: `testuser-${Date.now()}`,
    password: 'password123',
  };

  it('/auth/register (POST) — registers a new user', () => {
    return request(app.getHttpServer())
      .post('/auth/register')
      .send(testUser)
      .expect(201)
      .expect((res) => {
        expect(res.body.user.email).toBe(testUser.email);
        expect(res.body.user.userName).toBe(testUser.userName);
        expect(res.body.user.password).toBeUndefined();
      });
  });

  it('/auth/register (POST) — rejects duplicate email', () => {
    return request(app.getHttpServer())
      .post('/auth/register')
      .send(testUser)
      .expect(409);
  });

  it('/auth/login (POST) — returns JWT', () => {
    return request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: testUser.email, password: testUser.password })
      .expect(201)
      .expect((res) => {
        expect(res.body.accessToken).toBeDefined();
        expect(res.body.user.email).toBe(testUser.email);
      });
  });

  it('/auth/login (POST) — rejects wrong password', () => {
    return request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: testUser.email, password: 'wrong' })
      .expect(401);
  });

  it('/auth/me (GET) — rejects without token', () => {
    return request(app.getHttpServer()).get('/auth/me').expect(401);
  });

  it('/auth/me (GET) — returns profile with valid token', async () => {
    const loginRes = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: testUser.email, password: testUser.password });
    const token = loginRes.body.accessToken;

    return request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.email).toBe(testUser.email);
      });
  });
});
```

- [ ] **Step 2: Run e2e tests**

Run: `pnpm test:e2e -- --testPathPattern="auth" -t "Auth"`
Expected: Tests pass (note: tests connect to real database).

---

## Phase 2-4 Overview

### Phase 2: Public Browsing (4 endpoints)

- Task: Create RestaurantsModule with public controllers
- Endpoints:
  - `GET /restaurants` — list verified restaurants
  - `GET /restaurants/:id` — restaurant details
  - `GET /restaurants/:id/branches` — list branches for a restaurant
  - `GET /branches/:id/menu` — branch menu (dishes + drinks)

### Phase 3: User Wallet & Orders (7 endpoints)

- Task: Create WalletModule (wallet, top-up, transaction history)
- Task: Create OrdersModule (place order, list, details, cancel)
- Requires: Mobile money integration stubs

### Phase 4: Reviews & Notifications (6 endpoints)

- Task: Create ReviewsModule (dish, drink, branch reviews)
- Task: Notification infrastructure

### Phase 5: Admin Platform (24 endpoints)

- Task: Create AdminModule with admin-only guards
- CRUD for users, restaurants, admins, transactions, promotions
- System settings, payouts, special point grants

### Phase 6: Restaurant Admin (18 endpoints)

- Task: Create RestaurantAdminModule
- Branch management, menu management, staff management
- Order oversight, wallet overview

### Phase 7: Branch Admin (16 endpoints)

- Task: Create BranchAdminModule
- Menu overrides, order status updates, reviews
- Wallet, payout requests, notifications
