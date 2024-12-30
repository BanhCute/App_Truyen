import { NovelService } from './novel.service';
import { CreateNovelDto } from './dto/create-novel.dto';
import { UpdateNovelDto } from './dto/update-novel.dto';
import NovelDto from './dto/novel.dto';
import { Request } from 'express';
export declare class NovelController {
    private readonly novelService;
    constructor(novelService: NovelService);
    create(createNovelDto: CreateNovelDto, req: Request): NovelDto;
    findAll(): Promise<NovelDto[]>;
    findOne(id: number): NovelDto;
    update(id: number, updateNovelDto: UpdateNovelDto, req: Request): NovelDto;
    remove(id: number, req: Request): NovelDto;
    addCategories(id: number, categoryIds: number[], req: Request): Promise<NovelDto>;
    removeCategory(id: number, categoryId: number, req: Request): Promise<{
        id: number;
        categories: {
            category: {
                id: number;
                name: string;
            };
        }[];
    }>;
    getNovelRatings(id: number): Promise<({
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    } & {
        id: number;
        createdAt: Date;
        userId: number;
        novelId: number;
        content: string;
        score: number;
    })[]>;
    getAverageRating(id: number): Promise<{
        average: number;
    }>;
    rateNovel(id: number, ratingData: {
        score: number;
        content: string;
    }, req: Request): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    } & {
        id: number;
        createdAt: Date;
        userId: number;
        novelId: number;
        content: string;
        score: number;
    }>;
    updateRating(id: number, ratingId: number, ratingData: {
        score: number;
        content: string;
    }, req: Request): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    } & {
        id: number;
        createdAt: Date;
        userId: number;
        novelId: number;
        content: string;
        score: number;
    }>;
}
