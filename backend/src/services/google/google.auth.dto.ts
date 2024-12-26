import { Expose, Type } from 'class-transformer';
import { SessionResponseDto } from 'src/services/auth/dto/session.dto';

export class GoogleAuthResponse {
  @Expose()
  accessToken: string;

  @Expose()
  @Type(() => SessionResponseDto)
  user: SessionResponseDto;
}
