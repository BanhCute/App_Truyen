import { Expose } from 'class-transformer';
import NovelDto from 'src/services/novel/dto/novel.dto';

export default class RatingDto {
  @Expose()
  id: number;

  @Expose()
  novelId: number;

  @Expose()
  content: string;

  @Expose()
  score: number;

  @Expose()
  createdAt: Date;

  @Expose()
  novel: NovelDto;
}
