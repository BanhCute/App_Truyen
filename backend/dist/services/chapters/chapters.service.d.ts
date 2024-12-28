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
        content: string;
    }>;
    findAll(): Promise<({
        novel: {
            id: number;
            name: string;
            createdAt: Date;
            description: string | null;
            cover: string | null;
            author: string;
            status: string;
            view: number;
            updatedAt: Date;
            rating: number | null;
            followerCount: number;
            commentCount: number;
            userId: number;
        };
        Comment: {
            id: number;
            createdAt: Date;
            novelId: number | null;
            content: string;
            userId: number;
            chapterId: number;
        }[];
    } & {
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
        content: string;
    })[]>;
    findOne(id: number): Promise<{
        novel: {
            id: number;
            name: string;
            createdAt: Date;
            description: string | null;
            cover: string | null;
            author: string;
            status: string;
            view: number;
            updatedAt: Date;
            rating: number | null;
            followerCount: number;
            commentCount: number;
            userId: number;
        };
        Comment: {
            id: number;
            createdAt: Date;
            novelId: number | null;
            content: string;
            userId: number;
            chapterId: number;
        }[];
    } & {
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
        content: string;
    }>;
    update(id: number, updateChapterDto: UpdateChapterDto): Promise<{
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
        content: string;
    }>;
    remove(id: number): Promise<{
        id: number;
        name: string;
        createdAt: Date;
        novelId: number;
        content: string;
    }>;
}
