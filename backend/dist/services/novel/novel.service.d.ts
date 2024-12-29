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
        categories: ({
            category: {
                id: number;
                name: string;
                description: string | null;
            };
        } & {
            id: number;
            novelId: number;
            categoryId: number;
        })[];
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
    getNovelRatings(id: number): Promise<({
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    } & {
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number;
        content: string;
        score: number;
    })[]>;
    getAverageRating(id: number): Promise<{
        average: number;
    }>;
    rateNovel(id: number, userId: number, ratingData: {
        score: number;
        content: string;
    }): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    } & {
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number;
        content: string;
        score: number;
    }>;
    updateRating(novelId: number, ratingId: number, userId: number, ratingData: {
        score: number;
        content: string;
    }): Promise<{
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    } & {
        id: number;
        userId: number;
        createdAt: Date;
        novelId: number;
        content: string;
        score: number;
    }>;
}
