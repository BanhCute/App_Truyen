import { CreateNovelDto } from './dto/create-novel.dto';
import { UpdateNovelDto } from './dto/update-novel.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class NovelService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createNovelDto: CreateNovelDto, userId: number): Promise<{
        id: number;
        name: string;
        rating: number;
        view: number;
        userId: number;
        updatedAt: Date;
        createdAt: Date;
        description: string;
        cover: string;
        author: string;
        status: string;
        followerCount: number;
        commentCount: number;
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<{
        id: number;
        name: string;
        user: {
            id: number;
            name: string;
            avatar: string;
        };
        rating: number;
        view: number;
        userId: number;
        updatedAt: Date;
        createdAt: Date;
        description: string;
        categories: {
            category: {
                id: number;
                name: string;
            };
        }[];
        cover: string;
        author: string;
        status: string;
        followerCount: number;
        commentCount: number;
    }[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__NovelClient<{
        id: number;
        name: string;
        user: {
            id: number;
            name: string;
            avatar: string;
        };
        rating: number;
        view: number;
        userId: number;
        updatedAt: Date;
        createdAt: Date;
        description: string;
        categories: {
            category: {
                id: number;
                name: string;
            };
        }[];
        cover: string;
        author: string;
        status: string;
        followerCount: number;
        commentCount: number;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateNovelDto: UpdateNovelDto, userId: number): Promise<{
        id: number;
        name: string;
        rating: number;
        view: number;
        userId: number;
        updatedAt: Date;
        createdAt: Date;
        description: string;
        cover: string;
        author: string;
        status: string;
        followerCount: number;
        commentCount: number;
    }>;
    remove(id: number, userId: number): Promise<{
        id: number;
    }>;
    addCategories(id: number, categoryIds: number[], userId: number): Promise<{
        id: number;
        categories: {
            category: {
                id: number;
                name: string;
            };
        }[];
    }>;
    removeCategory(id: number, categoryId: number, userId: number): Promise<{
        id: number;
        categories: {
            category: {
                id: number;
                name: string;
            };
        }[];
    }>;
}
