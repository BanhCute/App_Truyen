import NovelDto from 'src/services/novel/dto/novel.dto';
import UserDto from 'src/services/users/dto/user.dto';
export default class RatingDto {
    id: number;
    novelId: number;
    userId: number;
    content: string;
    score: number;
    createdAt: Date;
    novel: NovelDto;
    user: UserDto;
}
