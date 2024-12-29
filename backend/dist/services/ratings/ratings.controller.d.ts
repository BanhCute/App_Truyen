import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import { Request } from 'express';
import { UpdateRatingDto } from './dto/update-rating.dto';
export declare class RatingsController {
    private readonly ratingsService;
    constructor(ratingsService: RatingsService);
    create(createRatingDto: CreateRatingDto, req: Request): Promise<{
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
            avatar: string;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        content: string;
        score: number;
        createdAt: Date;
    })[]>;
    findAllByNovelWithUser(novelId: number): Promise<({
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
    update(id: number, updateRatingDto: UpdateRatingDto, req: Request): Promise<{
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
