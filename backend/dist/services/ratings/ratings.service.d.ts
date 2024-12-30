import { DatabaseService } from '../database/database.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import { UpdateRatingDto } from './dto/update-rating.dto';
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
            avatar: string;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        content: string;
        score: number;
        createdAt: Date;
    }>;
    findAll(): Promise<{
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
            novel: {
                id: number;
                name: string;
                cover: string;
            };
        }[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
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
            novel: {
                id: number;
                name: string;
                cover: string;
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
            avatar: string;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        content: string;
        score: number;
        createdAt: Date;
    }>;
    update(id: number, updateRatingDto: UpdateRatingDto, userId: number): Promise<{
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
            avatar: string;
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
