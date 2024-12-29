import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import RatingDto from './dto/rating.dto';
import { Request } from 'express';
import { UpdateRatingDto } from './dto/update-rating.dto';
export declare class RatingsController {
    private readonly ratingsService;
    constructor(ratingsService: RatingsService);
    create(createRatingDto: CreateRatingDto, req: Request): RatingDto;
    findAll(): Promise<RatingDto[]>;
    findAllByNovelWithUser(novelId: number): Promise<RatingDto[]>;
    findOne(id: number): RatingDto;
    update(id: number, updateRatingDto: UpdateRatingDto, req: Request): RatingDto;
}
