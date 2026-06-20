import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from '../services/authService';
import { RegisterDto } from '../dto/registerDto';
import { LoginDto } from '../dto/loginDto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }
}
