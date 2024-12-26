import { DatabaseService } from '../database/database.service';
import { CreateHistoryDto } from './dto/create-history.dto';
export declare class HistorysService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createHistoryDto: CreateHistoryDto, userId: number): Promise<{
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
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<({
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
    } & {
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
    }>;
}
