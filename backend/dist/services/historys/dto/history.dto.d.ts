import NovelDto from 'src/services/novel/dto/novel.dto';
export default class HistoryDto {
    id: number;
    novelId: number;
    createdAt: Date;
    novel: NovelDto;
}
