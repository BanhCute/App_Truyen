import { Expose } from 'class-transformer';
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
  novel: NovelDto;

  @Expose()
  user: UserDto;
}
