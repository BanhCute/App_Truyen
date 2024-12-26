import { Module } from '@nestjs/common';
import { GoogleOauthController } from 'src/services/google/google.controller';
import { JwtAuthService } from 'src/services/jwt/jwt.service';
import { UsersService } from 'src/services/users/users.service';

@Module({
  controllers: [GoogleOauthController],
  providers: [UsersService, JwtAuthService],
})
export class GoogleModule {}
