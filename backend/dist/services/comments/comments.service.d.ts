import { CreateCommentDto } from './dto/create-comment.dto';
import { UpdateCommentDto } from './dto/update-comment.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class CommentsService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createCommentDto: CreateCommentDto, userId: number): Promise<{
        chapter: {
            id: number;
            createdAt: Date;
            novelId: number;
            name: string;
        };
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
    } & {
        id: number;
        chapterId: number;
        userId: number;
        content: string;
        createdAt: Date;
        novelId: number | null;
    }>;
    findAll(): Promise<({
        chapter: {
            id: number;
            createdAt: Date;
            novelId: number;
            name: string;
        };
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        Novel: {
            id: number;
            userId: number;
            createdAt: Date;
            name: string;
            description: string | null;
            cover: string | null;
            author: string;
            status: string;
            view: number;
            updatedAt: Date;
            rating: number | null;
            followerCount: number;
            commentCount: number;
        };
    } & {
        id: number;
        chapterId: number;
        userId: number;
        content: string;
        createdAt: Date;
        novelId: number | null;
    })[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__CommentClient<{
        chapter: {
            id: number;
            createdAt: Date;
            novelId: number;
            name: string;
        };
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        Novel: {
            id: number;
            userId: number;
            createdAt: Date;
            name: string;
            description: string | null;
            cover: string | null;
            author: string;
            status: string;
            view: number;
            updatedAt: Date;
            rating: number | null;
            followerCount: number;
            commentCount: number;
        };
    } & {
        id: number;
        chapterId: number;
        userId: number;
        content: string;
        createdAt: Date;
        novelId: number | null;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateCommentDto: UpdateCommentDto): Promise<void>;
    remove(id: number, userId: number): Promise<{
        id: number;
        chapterId: number;
        userId: number;
        content: string;
        createdAt: Date;
        novelId: number | null;
    }>;
}
