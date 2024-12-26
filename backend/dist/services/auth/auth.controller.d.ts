import { Request, Response } from 'express';
import { ConfigService } from '@nestjs/config';
import { AppConfig } from 'src/config/configuration';
export declare class AuthController {
    private configService;
    constructor(configService: ConfigService<AppConfig>);
    logout(req: Request, res: Response): void;
}
