import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { Profile, Strategy } from 'passport-github';

import { UsersService } from '../users/users.service';
import { AppConfig } from 'src/config/configuration';
import { SessionDto } from 'src/services/auth/dto/session.dto';

@Injectable()
export class GithubOauthStrategy extends PassportStrategy(Strategy, 'github') {
  constructor(
    private configService: ConfigService<AppConfig>,
    private usersService: UsersService,
  ) {
    super({
      clientID: configService.get('auth')?.github?.clientId,
      clientSecret: configService.get('auth')?.github?.clientSecret,
      callbackURL: configService.get('auth')?.github?.callbackURL,
      scope: ['public_profile'],
    });
  }

  async validate(
    _accessToken: string,
    _refreshToken: string,
    profile: Profile,
  ): Promise<SessionDto> {
    const { id, displayName, profileUrl, name, username } = profile;
    let user = await this.usersService.find(id, 'github');

    if (!user) {
      user = await this.usersService.create(id, 'github', {
        name: displayName ?? username ?? name,
        profileUrl,
      });
    }

    return user;
  }
}
