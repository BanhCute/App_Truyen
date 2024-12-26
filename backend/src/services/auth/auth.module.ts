import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { JwtModule } from '@nestjs/jwt';
import { GithubModule } from '../github/github.module';
import { JwtAuthService } from 'src/services/jwt/jwt.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AppConfig } from '../../config/configuration';
import { AuthMiddleware } from 'src/services/auth/auth.middleware';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService<AppConfig>) => {
        return {
          secret: configService.get<string>('auth.jwt.secret'),
          signOptions: { expiresIn: '3d' },
        };
      },
      global: true,
    }),
    GithubModule,
    JwtModule,
  ],
  controllers: [AuthController],
  providers: [JwtAuthService, AuthMiddleware],
  exports: [JwtAuthService, AuthMiddleware],
})
export class AuthModule {}
