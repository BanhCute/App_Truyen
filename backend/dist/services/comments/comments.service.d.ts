import { CreateCommentDto } from './dto/create-comment.dto';
import { UpdateCommentDto } from './dto/update-comment.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class CommentsService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createCommentDto: CreateCommentDto, userId: number): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        chapter: {
            id: number;
            name: string;
            createdAt: Date;
            novelId: number;
            content: string;
        };
    } & {
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number | null;
        content: string;
        chapterId: number;
    }>;
    findAll(): Promise<({
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        chapter: {
            id: number;
            name: string;
            createdAt: Date;
            novelId: number;
            content: string;
        };
        Novel: {
            id: number;
            name: string;
            rating: number | null;
            view: number;
            userId: number;
            updatedAt: Date;
            createdAt: Date;
            description: string | null;
            cover: string | null;
            author: string;
            status: string;
            followerCount: number;
            commentCount: number;
        };
    } & {
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number | null;
        content: string;
        chapterId: number;
    })[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__CommentClient<{
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        chapter: {
            id: number;
            name: string;
            createdAt: Date;
            novelId: number;
            content: string;
        };
        Novel: {
            id: number;
            name: string;
            rating: number | null;
            view: number;
            userId: number;
            updatedAt: Date;
            createdAt: Date;
            description: string | null;
            cover: string | null;
            author: string;
            status: string;
            followerCount: number;
            commentCount: number;
        };
    } & {
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number | null;
        content: string;
        chapterId: number;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateCommentDto: UpdateCommentDto): Promise<void>;
    remove(id: number, userId: number): Promise<{
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number | null;
        content: string;
        chapterId: number;
    }>;
}
