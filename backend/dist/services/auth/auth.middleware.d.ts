import { NestMiddleware } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Request, Response, NextFunction } from 'express';
import { AppConfig } from 'src/config/configuration';
export declare class AuthMiddleware implements NestMiddleware {
    private jwtService;
    private configService;
    constructor(jwtService: JwtService, configService: ConfigService<AppConfig>);
    use(req: Request, res: Response, next: NextFunction): Promise<void>;
    private extractToken;
}
