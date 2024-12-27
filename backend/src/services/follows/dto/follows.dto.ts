import { Expose, Type } from 'class-transformer';
import NovelDto from 'src/services/novel/dto/novel.dto';
import { UserResponse } from 'src/services/users/dto/user.response';

export default class FollowDto {
  @Expose()
  id: number;

  @Expose()
  novelId: number;

  @Expose()
  userId: number;

  @Expose()
  createdAt: Date;

  @Expose()
  @Type(() => NovelDto)
  novel: NovelDto;
}
