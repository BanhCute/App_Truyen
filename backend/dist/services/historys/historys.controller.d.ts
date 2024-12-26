import { HistorysService } from './historys.service';
import { CreateHistoryDto } from './dto/create-history.dto';
import HistoryDto from './dto/history.dto';
import { Request } from 'express';
export declare class HistorysController {
    private readonly historysService;
    constructor(historysService: HistorysService);
    create(createHistoryDto: CreateHistoryDto, req: Request): HistoryDto;
    findAll(): Promise<HistoryDto[]>;
    findOne(id: number): HistoryDto;
    remove(id: number, req: Request): HistoryDto;
}
