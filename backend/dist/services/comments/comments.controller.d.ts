import { CommentsService } from './comments.service';
import { CreateCommentDto } from './dto/create-comment.dto';
import CommentDto from './dto/comments.dto';
import { Request } from 'express';
export declare class CommentsController {
    private readonly commentsService;
    constructor(commentsService: CommentsService);
    create(createCommentDto: CreateCommentDto, req: Request): Promise<CommentDto>;
    findAll(): Promise<CommentDto[]>;
    findOne(id: number): CommentDto;
    remove(id: number, req: Request): Promise<{
        id: number;
        novelId: number | null;
        userId: number;
        createdAt: Date;
        content: string;
        chapterId: number;
    }>;
}
