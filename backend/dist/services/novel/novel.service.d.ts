import { CreateNovelDto } from './dto/create-novel.dto';
import { UpdateNovelDto } from './dto/update-novel.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class NovelService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createNovelDto: CreateNovelDto, userId: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        createdAt: Date;
        cover: string | null;
        author: string;
        status: string;
        view: number;
        updatedAt: Date;
        rating: number | null;
        followerCount: number;
        commentCount: number;
        userId: number;
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<({
        chapters: {
            id: number;
            name: string;
            createdAt: Date;
            novelId: number;
        }[];
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
    } & {
        id: number;
        name: string;
        description: string | null;
        createdAt: Date;
        cover: string | null;
        author: string;
        status: string;
        view: number;
        updatedAt: Date;
        rating: number | null;
        followerCount: number;
        commentCount: number;
        userId: number;
    })[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__NovelClient<{
        chapters: {
            id: number;
            name: string;
            createdAt: Date;
            novelId: number;
        }[];
        ratings: {
            id: number;
            createdAt: Date;
            userId: number;
            novelId: number;
            content: string;
            score: number;
        }[];
        comments: {
            id: number;
            createdAt: Date;
            userId: number;
            novelId: number | null;
            content: string;
            chapterId: number;
        }[];
        user: {
            id: number;
            name: string;
            avatar: string | null;
            isDeleted: boolean;
            isBanned: boolean;
        };
    } & {
        id: number;
        name: string;
        description: string | null;
        createdAt: Date;
        cover: string | null;
        author: string;
        status: string;
        view: number;
        updatedAt: Date;
        rating: number | null;
        followerCount: number;
        commentCount: number;
        userId: number;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateNovelDto: UpdateNovelDto, userId: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        createdAt: Date;
        cover: string | null;
        author: string;
        status: string;
        view: number;
        updatedAt: Date;
        rating: number | null;
        followerCount: number;
        commentCount: number;
        userId: number;
    }>;
    remove(id: number, userId: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        createdAt: Date;
        cover: string | null;
        author: string;
        status: string;
        view: number;
        updatedAt: Date;
        rating: number | null;
        followerCount: number;
        commentCount: number;
        userId: number;
    }>;
}
