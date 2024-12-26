import NovelDto from 'src/services/novel/dto/novel.dto';
import { UserResponse } from 'src/services/users/dto/user.response';
export default class FollowDto {
    id: number;
    novelId: number;
    userId: number;
    createdAt: Date;
    novel: NovelDto;
    user: UserResponse;
}
