import NovelDto from 'src/services/novel/dto/novel.dto';
export default class RatingDto {
    id: number;
    novelId: number;
    content: string;
    score: number;
    createdAt: Date;
    novel: NovelDto;
}
