import { DatabaseService } from '../database/database.service';
import { CreateRatingDto } from './dto/create-rating.dto';
export declare class RatingsService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createRatingDto: CreateRatingDto, userId: number): Promise<{
        novel: {
            rating: number | null;
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
        content: string;
        score: number;
        createdAt: Date;
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<({
        novel: {
            rating: number | null;
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
        content: string;
        score: number;
        createdAt: Date;
    })[]>;
    findOne(id: number): Promise<{
        novel: {
            rating: number | null;
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
        content: string;
        score: number;
        createdAt: Date;
    }>;
}
