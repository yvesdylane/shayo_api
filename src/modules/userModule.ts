import { Module } from '@nestjs/common';
import { UserService } from '../services/userService';
import { UserController } from '../controllers/userController';
import { AuthModule } from './authModule';

@Module({
  imports: [AuthModule],
  providers: [UserService],
  controllers: [UserController],
  exports: [UserService],
})
export class UserModule {}
