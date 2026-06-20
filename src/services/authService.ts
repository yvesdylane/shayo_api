import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from './prismaService';
import { RegisterDto } from '../dto/registerDto';
import { LoginDto } from '../dto/loginDto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existingEmail = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (existingEmail) {
      throw new ConflictException('Email already registered');
    }

    const existingUsername = await this.prisma.user.findUnique({
      where: { userName: dto.userName },
    });
    if (existingUsername) {
      throw new ConflictException('Username already taken');
    }

    const existingPhone = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
    });
    if (existingPhone) {
      throw new ConflictException('Phone number already registered');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 12);

    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        userName: dto.userName,
        password: hashedPassword,
        phone: dto.phone,
        firstName: dto.firstName,
        surName: dto.surName,
      },
    });

    const token = this.generateToken(user.id, user.email);

    return { user: this.omitPassword(user), token };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isValid = await bcrypt.compare(dto.password, user.password);
    if (!isValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const token = this.generateToken(user.id, user.email);

    return { user: this.omitPassword(user), token };
  }

  private generateToken(userId: string, email: string): string {
    return this.jwtService.sign({ sub: userId, email });
  }

  private omitPassword(user: { password: string; [key: string]: any }) {
    const { password: _, ...rest } = user;
    return rest;
  }
}
