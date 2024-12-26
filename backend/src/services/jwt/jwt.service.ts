import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { SessionDto } from 'src/services/auth/dto/session.dto';
import { JwtPayload } from 'src/types/auth';

@Injectable()
export class JwtAuthService {
  constructor(private jwtService: JwtService) {}

  login(user: SessionDto) {
    const { id } = user;
    const payload: JwtPayload = {
      sub: id,
      ...user,
    };

    return {
      accessToken: this.jwtService.sign(payload),
    };
  }
}
