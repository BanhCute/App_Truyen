import { Expose } from 'class-transformer';
import NovelDto from 'src/services/novel/dto/novel.dto';
import CommentDto from 'src/services/comments/dto/comments.dto';

export default class ChapterDto {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  content: string;

  @Expose()
  createdAt: Date;

  @Expose()
  novelId: number;

  @Expose()
  novel: NovelDto;

  @Expose()
  Comment: CommentDto[];
}
