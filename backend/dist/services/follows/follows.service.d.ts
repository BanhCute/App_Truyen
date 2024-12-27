import { DatabaseService } from '../database/database.service';
import { CreateFollowDto } from './dto/create-follow.dto';
export declare class FollowsService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createFollowDto: CreateFollowDto, userId: number): Promise<{
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number;
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<({
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        novel: {
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
        novelId: number;
    })[]>;
    findOne(id: number): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        novel: {
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
        novelId: number;
    }>;
    remove(id: number, userId: number): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        novel: {
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
        novelId: number;
    }>;
    removeByNovelId(novelId: number, userId: number): Promise<{
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number;
    }>;
}
