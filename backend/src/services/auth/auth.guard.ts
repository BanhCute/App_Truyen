import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { Request } from 'express';
import { getSessionOrNull } from 'src/services/auth/auth.utils';
@Injectable()
export class AuthGuard implements CanActivate {
  constructor() {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request: Request = context.switchToHttp().getRequest();

    const user = getSessionOrNull(request);

    if (!user) {
      throw new UnauthorizedException();
    }

    return true;
  }
}
