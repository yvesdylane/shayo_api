import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerModule } from '@nestjs/throttler';
import { AppController } from '../controllers/appController';
import { AppService } from '../services/appService';
import { PrismaModule } from './prismaModule';
import { AuthModule } from './authModule';
import { UserModule } from './userModule';
import { ThrottlerBehindProxyGuard } from '../guards/throttlerGuard';

@Module({
  imports: [
    ThrottlerModule.forRoot([{ name: 'global', ttl: 60000, limit: 30 }]),
    PrismaModule,
    AuthModule,
    UserModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    { provide: APP_GUARD, useClass: ThrottlerBehindProxyGuard },
  ],
})
export class AppModule {}
