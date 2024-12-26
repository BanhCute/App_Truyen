import { UnauthorizedException } from '@nestjs/common';
import { Request } from 'express';
import { SessionDto } from 'src/services/auth/dto/session.dto';

export function getSessionOrNull(req: Request): SessionDto | null {
  //@ts-ignore
  const user = req.user as unknown as SessionDto;

  if (!user) {
    return null;
  }

  return {
    id: user.id,
    name: user.name,
    avatar: user.avatar,
    authorities: user.authorities,
    roles: user.roles,
  };
}

export function getSession(req: Request): SessionDto {
  //@ts-ignore
  const user = req.user as unknown as SessionDto;

  if (!user) {
    throw new UnauthorizedException();
  }

  return {
    id: user.id,
    name: user.name,
    avatar: user.avatar,
    authorities: user.authorities,
    roles: user.roles,
  };
}
