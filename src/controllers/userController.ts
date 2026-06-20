import { Controller, Get, UseGuards } from '@nestjs/common';
import { UserService } from '../services/userService';
import { JwtAuthGuard } from '../guards/jwtAuthGuard';
import { CurrentUser } from '../decorators/currentUserDecorator';

@Controller('user')
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('me')
  getProfile(@CurrentUser() user: { userId: string }) {
    return this.userService.findById(user.userId);
  }
}
