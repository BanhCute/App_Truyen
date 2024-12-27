import { DatabaseService } from '../database/database.service';
import { CreateFollowDto } from './dto/create-follow.dto';
export declare class FollowsService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createFollowDto: CreateFollowDto, userId: number): Promise<{
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
    }>;
    findAll(userId: number): import("@prisma/client").Prisma.PrismaPromise<({
        novel: {
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
        novelId: number;
        userId: number;
        createdAt: Date;
    })[]>;
    findOne(id: number): Promise<{
        novel: {
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
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
    }>;
    remove(id: number, userId: number): Promise<{
        novel: {
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
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
    }>;
    removeByNovelId(novelId: number, userId: number): Promise<{
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
    }>;
}
