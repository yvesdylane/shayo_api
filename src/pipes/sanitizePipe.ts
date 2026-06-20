import { PipeTransform, Injectable } from '@nestjs/common';

@Injectable()
export class SanitizePipe implements PipeTransform {
  transform(value: any) {
    return this.sanitize(value);
  }

  private sanitize(value: any): any {
    if (typeof value === 'string') {
      return value.trim().replace(/<[^>]*>/g, '');
    }
    if (Array.isArray(value)) {
      return value.map((v) => this.sanitize(v));
    }
    if (value && typeof value === 'object' && value.constructor === Object) {
      const sanitized: Record<string, any> = {};
      for (const key of Object.keys(value)) {
        sanitized[key] = this.sanitize(value[key]);
      }
      return sanitized;
    }
    return value;
  }
}
