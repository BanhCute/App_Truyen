import NovelDto from 'src/services/novel/dto/novel.dto';
import CommentDto from 'src/services/comments/dto/comments.dto';
export default class ChapterDto {
    id: number;
    name: string;
    content: string;
    createdAt: Date;
    novelId: number;
    novel: NovelDto;
    Comment: CommentDto[];
}
