import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import RatingDto from './dto/rating.dto';
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
    findAll(novelId: number, page: number, limit: number): Promise<RatingDto[] | {
        items: RatingDto[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    findAllByNovelWithUser(novelId: number, page: number, limit: number): Promise<{
        items: RatingDto[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
    }>;
    findOne(id: number): Promise<RatingDto>;
    update(id: number, updateRatingDto: UpdateRatingDto, req: Request): Promise<RatingDto>;
}
