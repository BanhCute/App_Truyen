import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import RatingDto from './dto/rating.dto';
import { Request } from 'express';
import { UpdateRatingDto } from './dto/update-rating.dto';
export declare class RatingsController {
    private readonly ratingsService;
    constructor(ratingsService: RatingsService);
    create(createRatingDto: CreateRatingDto, req: Request): Promise<RatingDto>;
    findAll(novelId: number, page: number, limit: number): Promise<{
        items: RatingDto[];
        meta: {
            page: number;
            limit: number;
            total: number;
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
