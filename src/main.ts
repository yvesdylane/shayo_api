import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';
import { AppModule } from './modules/appModule';
import { SanitizePipe } from './pipes/sanitizePipe';
import { auth } from './auth/betterAuth';
import { toNodeHandler } from 'better-auth/node';

const BETTER_AUTH_PATHS = [
  '/sign-in',
  '/callback',
  '/sign-out',
  '/get-session',
  '/list-sessions',
  '/revoke-session',
  '/revoke-other-sessions',
  '/change-password',
  '/change-email',
  '/set-password',
  '/update-user',
  '/delete-user',
  '/link-social',
  '/unlink-account',
  '/list-accounts',
  '/refresh-token',
  '/get-access-token',
  '/forgot-password',
  '/reset-password',
  '/verify-email',
  '/send-verification-email',
  '/ok',
  '/error',
];

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors({
    origin: process.env.FRONTEND_URL ?? 'http://localhost:5173',
    credentials: true,
  });

  app.use(
    helmet({
      contentSecurityPolicy: {
        directives: {
          scriptSrc: ["'self'", "'unsafe-inline'"],
        },
      },
    }),
  );

  const authHandler = toNodeHandler(auth);
  app.use((req, res, next) => {
    if (BETTER_AUTH_PATHS.some((p) => req.path.startsWith(p))) {
      return authHandler(req, res).catch(next);
    }
    next();
  });

  app.useGlobalPipes(
    new SanitizePipe(),
    new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }),
  );

  await app.listen(process.env.PORT ?? 3000);
}

void bootstrap();
