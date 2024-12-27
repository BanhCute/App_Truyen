import { Injectable, NestMiddleware } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Request, Response, NextFunction, request } from 'express';
import { AppConfig } from 'src/config/configuration';

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  constructor(
    private jwtService: JwtService,
    private configService: ConfigService<AppConfig>,
  ) {}

  async use(req: Request, res: Response, next: NextFunction) {
    // Lấy token từ cookie hoặc header Authorization
    const token = this.extractToken(req);

    if (!token) {
      req['user'] = null;
      return next();
    }

    try {
      const { sub, ...payload } = await this.jwtService.verifyAsync(token, {
        secret: this.configService.get<string>('auth.jwt.secret'),
      });

      req['user'] = { ...payload, id: +sub };
    } catch (error) {
      // Xóa cookie nếu token không hợp lệ
      res.clearCookie('jwt');
      req['user'] = null;
    }

    next();
  }

  private extractToken(req: Request): string | null {
    // Thử lấy từ cookie
    const cookieToken = req?.cookies?.jwt;
    if (cookieToken) return cookieToken;

    // Thử lấy từ header Authorization
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7); // Bỏ 'Bearer ' ở đầu
    }

    return null;
  }
}
