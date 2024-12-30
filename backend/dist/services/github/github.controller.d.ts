import { ConfigService } from '@nestjs/config';
import { Request, Response } from 'express';
import { JwtAuthService } from 'src/services/jwt/jwt.service';
import { AppConfig } from 'src/config/configuration';
export declare class GithubOauthController {
    private jwtAuthService;
    private configService;
    constructor(jwtAuthService: JwtAuthService, configService: ConfigService<AppConfig>);
    githubAuth(): Promise<void>;
    githubAuthCallback(req: Request, res: Response): Promise<void>;
}
