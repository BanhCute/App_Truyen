import NovelDto from 'src/services/novel/dto/novel.dto';
export default class FollowDto {
    id: number;
    novelId: number;
    userId: number;
    createdAt: Date;
    novel: NovelDto;
}
