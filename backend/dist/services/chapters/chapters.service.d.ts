import { CreateChapterDto } from './dto/create-chapter.dto';
import { UpdateChapterDto } from './dto/update-chapter.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class ChaptersService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createChapterDto: CreateChapterDto): Promise<{
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
    }>;
    findAll(): Promise<({
        novel: {
            id: number;
            name: string;
            rating: number | null;
            view: number;
            userId: number;
            updatedAt: Date;
            createdAt: Date;
            description: string | null;
            cover: string | null;
            author: string;
            status: string;
            followerCount: number;
            commentCount: number;
        };
        Comment: {
            id: number;
            userId: number;
            createdAt: Date;
            novelId: number | null;
            chapterId: number;
            content: string;
        }[];
    } & {
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
    })[]>;
    findOne(id: number): Promise<{
        novel: {
            id: number;
            name: string;
            rating: number | null;
            view: number;
            userId: number;
            updatedAt: Date;
            createdAt: Date;
            description: string | null;
            cover: string | null;
            author: string;
            status: string;
            followerCount: number;
            commentCount: number;
        };
        Comment: {
            id: number;
            userId: number;
            createdAt: Date;
            novelId: number | null;
            chapterId: number;
            content: string;
        }[];
    } & {
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
    }>;
    update(id: number, updateChapterDto: UpdateChapterDto): Promise<{
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
    }>;
    remove(id: number): Promise<{
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
    }>;
}
