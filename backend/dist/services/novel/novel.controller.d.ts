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
}
