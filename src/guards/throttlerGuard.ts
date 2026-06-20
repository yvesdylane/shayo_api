import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

@Injectable()
export class ThrottlerBehindProxyGuard extends ThrottlerGuard {
  protected getTracker(req: Record<string, any>): Promise<string> {
    const forwarded = req.headers?.['x-forwarded-for'];
    if (forwarded) {
      return Promise.resolve(
        Array.isArray(forwarded)
          ? forwarded[0].trim()
          : forwarded.split(',')[0].trim(),
      );
    }
    return Promise.resolve(req.ip ?? req.socket?.remoteAddress ?? 'unknown');
  }
}
