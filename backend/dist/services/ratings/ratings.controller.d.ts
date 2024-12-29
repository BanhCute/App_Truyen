import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import { Request } from 'express';
import { UpdateRatingDto } from './dto/update-rating.dto';
export declare class RatingsController {
    private readonly ratingsService;
    constructor(ratingsService: RatingsService);
    create(createRatingDto: CreateRatingDto, req: Request): Promise<{
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
            avatar: string;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
        content: string;
        score: number;
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
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
        content: string;
        score: number;
    })[]>;
    findAllByNovelWithUser(novelId: number): Promise<({
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
            avatar: string;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
        content: string;
        score: number;
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
            avatar: string;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
        content: string;
        score: number;
    }>;
    update(id: number, updateRatingDto: UpdateRatingDto, req: Request): Promise<{
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
            avatar: string;
        };
    } & {
        id: number;
        novelId: number;
        userId: number;
        createdAt: Date;
        content: string;
        score: number;
    }>;
}
