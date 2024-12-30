import { ConfigService } from '@nestjs/config';
import { Profile } from 'passport-github';
import { UsersService } from '../users/users.service';
import { AppConfig } from 'src/config/configuration';
import { SessionDto } from 'src/services/auth/dto/session.dto';
declare const GithubOauthStrategy_base: new (...args: any[]) => any;
export declare class GithubOauthStrategy extends GithubOauthStrategy_base {
    private configService;
    private usersService;
    constructor(configService: ConfigService<AppConfig>, usersService: UsersService);
    validate(_accessToken: string, _refreshToken: string, profile: Profile): Promise<SessionDto>;
}
export {};
