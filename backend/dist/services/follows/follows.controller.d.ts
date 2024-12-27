import { FollowsService } from './follows.service';
import { CreateFollowDto } from './dto/create-follow.dto';
import FollowDto from './dto/follows.dto';
import { Request } from 'express';
export declare class FollowsController {
    private readonly followsService;
    constructor(followsService: FollowsService);
    create(createFollowDto: CreateFollowDto, req: Request): FollowDto;
    findAll(): Promise<FollowDto[]>;
    findOne(id: number): FollowDto;
    remove(id: number, req: Request): FollowDto;
    removeByNovelId(novelId: number, req: Request): Promise<FollowDto>;
}
