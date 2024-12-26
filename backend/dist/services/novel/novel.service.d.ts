import { CreateNovelDto } from './dto/create-novel.dto';
import { UpdateNovelDto } from './dto/update-novel.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class NovelService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createNovelDto: CreateNovelDto, userId: number): Promise<{
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
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<({
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        chapters: {
            id: number;
            name: string;
            createdAt: Date;
            novelId: number;
            content: string;
        }[];
    } & {
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
    })[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__NovelClient<{
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
        comments: {
            id: number;
            userId: number;
            createdAt: Date;
            novelId: number | null;
            content: string;
            chapterId: number;
        }[];
        chapters: {
            id: number;
            name: string;
            createdAt: Date;
            novelId: number;
            content: string;
        }[];
        ratings: {
            id: number;
            userId: number;
            createdAt: Date;
            novelId: number;
            content: string;
            score: number;
        }[];
    } & {
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
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateNovelDto: UpdateNovelDto, userId: number): Promise<{
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
    }>;
    remove(id: number, userId: number): Promise<{
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
    }>;
}
