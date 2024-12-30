import { Expose, Type } from 'class-transformer';
import NovelDto from 'src/services/novel/dto/novel.dto';
import UserDto from 'src/services/users/dto/user.dto';

export default class RatingDto {
  @Expose()
  id: number;

  @Expose()
  novelId: number;

  @Expose()
  userId: number;

  @Expose()
  content: string;

  @Expose()
  score: number;

  @Expose()
  createdAt: Date;

  @Expose()
  @Type(() => NovelDto)
  novel?: NovelDto;

  @Expose()
  @Type(() => UserDto)
  user?: UserDto;

  @Expose()
  userName?: string;

  @Expose()
  userAvatar?: string;

  constructor(partial: Partial<RatingDto>) {
    Object.assign(this, partial);
  }
}
