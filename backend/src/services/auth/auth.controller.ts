import { Controller, Get, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import { ConfigService } from '@nestjs/config';
import { AppConfig } from 'src/config/configuration';

@Controller('auth')
export class AuthController {
  constructor(private configService: ConfigService<AppConfig>) {}
  @Get('logout')
  logout(@Req() req: Request, @Res({ passthrough: true }) res: Response) {
    res.clearCookie('jwt');

    return res.redirect(`${this.configService.get('url.frontend')}`);
  }
}
