import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import RatingDto from './dto/rating.dto';
import { Request } from 'express';
export declare class RatingsController {
    private readonly ratingsService;
    constructor(ratingsService: RatingsService);
    create(createRatingDto: CreateRatingDto, req: Request): RatingDto;
    findAll(): Promise<RatingDto[]>;
    findOne(id: number): RatingDto;
}
