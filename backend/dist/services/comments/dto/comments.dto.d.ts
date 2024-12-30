import ChapterDto from 'src/services/chapters/dto/chapter.dto';
import NovelDto from 'src/services/novel/dto/novel.dto';
import { UserResponse } from 'src/services/users/dto/user.response';
export default class CommentDto {
    id: number;
    chapterId: number;
    userId: number;
    content: string;
    createdAt: Date;
    chapter: ChapterDto;
    user: UserResponse;
    novelId?: number;
    Novel?: NovelDto;
}
