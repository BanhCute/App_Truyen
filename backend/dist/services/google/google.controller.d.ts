import { ConfigService } from '@nestjs/config';
import { Request } from 'express';
import { AppConfig } from 'src/config/configuration';
import { UsersService } from 'src/services/users/users.service';
import { JwtAuthService } from 'src/services/jwt/jwt.service';
import { GoogleAuthResponse } from 'src/services/google/google.auth.dto';
export declare class GoogleOauthController {
    private configService;
    private usersService;
    private jwtService;
    private google;
    constructor(configService: ConfigService<AppConfig>, usersService: UsersService, jwtService: JwtAuthService);
    googleAuthCallback(req: Request): Promise<GoogleAuthResponse>;
}
