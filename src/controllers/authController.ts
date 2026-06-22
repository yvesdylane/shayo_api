import { Controller, Post, Body, Req } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from '../services/authService';
import { RegisterDto } from '../dto/registerDto';
import { LoginDto } from '../dto/loginDto';
import { GoogleExchangeDto } from '../dto/googleExchangeDto';
import type { Request } from 'express';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @Throttle({ global: { limit: 3, ttl: 3600000 } })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @Throttle({ global: { limit: 10, ttl: 60000 } })
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('google')
  @Throttle({ global: { limit: 10, ttl: 60000 } })
  googleExchange(@Body() dto: GoogleExchangeDto) {
    return this.authService.googleExchange(dto.token);
  }

  @Post('exchange')
  @Throttle({ global: { limit: 10, ttl: 60000 } })
  exchange(@Req() req: Request) {
    return this.authService.exchange(req.headers);
  }
}
