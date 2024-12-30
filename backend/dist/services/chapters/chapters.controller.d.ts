import { ChaptersService } from './chapters.service';
import { CreateChapterDto } from './dto/create-chapter.dto';
import { UpdateChapterDto } from './dto/update-chapter.dto';
import ChapterDto from './dto/chapter.dto';
export declare class ChaptersController {
    private readonly chaptersService;
    constructor(chaptersService: ChaptersService);
    create(createChapterDto: CreateChapterDto): Promise<ChapterDto>;
    findAll(): Promise<ChapterDto[]>;
    findOne(id: number): Promise<ChapterDto>;
    update(id: number, updateChapterDto: UpdateChapterDto): Promise<ChapterDto>;
    remove(id: number): Promise<ChapterDto>;
}
