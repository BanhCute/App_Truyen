import { ConfigService } from '@nestjs/config';
import { AppConfig } from 'src/config/configuration';
import { JwtPayload } from 'src/types/auth';
declare const JwtStrategy_base: new (...args: any[]) => any;
export declare class JwtStrategy extends JwtStrategy_base {
    private configService;
    constructor(configService: ConfigService<AppConfig>);
    validate(payload: JwtPayload): Promise<{
        sub: number;
        iat?: number;
        exp?: number;
        name: string;
        avatar: string | null;
        roles: string[];
        authorities: string[];
        id: number;
    }>;
}
export {};
