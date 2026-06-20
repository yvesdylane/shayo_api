import { Module } from '@nestjs/common';
import { AppController } from '../controllers/appController';
import { AppService } from '../services/appService';
import { PrismaModule } from './prismaModule';
import { AuthModule } from './authModule';
import { UserModule } from './userModule';

@Module({
  imports: [PrismaModule, AuthModule, UserModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
