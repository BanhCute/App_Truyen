import { Expose } from 'class-transformer';
import NovelDto from 'src/services/novel/dto/novel.dto';

export default class HistoryDto {
  @Expose()
  id: number;

  @Expose()
  novelId: number;

  @Expose()
  createdAt: Date;

  @Expose()
  novel: NovelDto;
}
