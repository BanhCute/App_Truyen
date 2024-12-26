import { Expose } from 'class-transformer';
import ChapterDto from 'src/services/chapters/dto/chapter.dto';
import NovelDto from 'src/services/novel/dto/novel.dto';
import { UserResponse } from 'src/services/users/dto/user.response';

export default class CommentDto {
  @Expose()
  id: number;

  @Expose()
  chapterId: number;

  @Expose()
  userId: number;

  @Expose()
  content: string;

  @Expose()
  createdAt: Date;

  @Expose()
  chapter: ChapterDto;

  @Expose()
  user: UserResponse;

  @Expose()
  novelId?: number;

  @Expose()
  Novel?: NovelDto;
}
