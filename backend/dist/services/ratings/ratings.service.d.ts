import { DatabaseService } from '../database/database.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import { UpdateRatingDto } from './dto/update-rating.dto';
export declare class RatingsService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createRatingDto: CreateRatingDto, userId: number): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string;
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
        content: string;
        score: number;
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<({
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    } & {
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number;
        content: string;
        score: number;
    })[]>;
    findAllByNovelWithUser(novelId: number, page?: number, limit?: number): Promise<{
        items: {
            id: number;
            novelId: number;
            userId: number;
            content: string;
            score: number;
            createdAt: Date;
            user: {
                id: number;
                name: string;
                avatar: string;
            };
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
    }>;
    findOne(id: number): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string;
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
        content: string;
        score: number;
    }>;
    update(id: number, updateRatingDto: UpdateRatingDto, userId: number): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string;
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
        content: string;
        score: number;
    }>;
}
