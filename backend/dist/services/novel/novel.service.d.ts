import { CreateNovelDto } from './dto/create-novel.dto';
import { UpdateNovelDto } from './dto/update-novel.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class NovelService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createNovelDto: CreateNovelDto, userId: number): Promise<{
        id: number;
        name: string;
        description: string;
        createdAt: Date;
        cover: string;
        author: string;
        status: string;
        view: number;
        updatedAt: Date;
        rating: number;
        followerCount: number;
        commentCount: number;
        userId: number;
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<{
        id: number;
        name: string;
        description: string;
        createdAt: Date;
        cover: string;
        author: string;
        status: string;
        view: number;
        updatedAt: Date;
        rating: number;
        followerCount: number;
        commentCount: number;
        userId: number;
        user: {
            id: number;
            name: string;
            avatar: string;
        };
        categories: {
            category: {
                id: number;
                name: string;
            };
        }[];
    }[]>;
    findOne(id: number): Promise<{
        id: number;
        name: string;
        description: string;
        author: string;
        cover: string;
        status: string;
        view: number;
        rating: number;
        followerCount: number;
        commentCount: number;
        createdAt: Date;
        updatedAt: Date;
        userId: number;
        user: {
            id: number;
            name: string;
            avatar: string;
        };
        categories: {
            id: number;
            name: string;
            description: string;
        }[];
        ratings: {
            id: number;
            content: string;
            score: number;
            createdAt: Date;
            userId: number;
            user: {
                id: number;
                name: string;
                avatar: string;
            };
        }[];
    }>;
    update(id: number, updateNovelDto: UpdateNovelDto, userId: number): Promise<{
        id: number;
        name: string;
        description: string;
        createdAt: Date;
        cover: string;
        author: string;
        status: string;
        view: number;
        updatedAt: Date;
        rating: number;
        followerCount: number;
        commentCount: number;
        userId: number;
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
    removeCategory(id: number, categoryId: number, userId: number): Promise<{
        id: number;
        categories: {
            category: {
                id: number;
                name: string;
            };
        }[];
    }>;
    getNovelRatings(id: number): Promise<{
        id: number;
        content: string;
        score: number;
        createdAt: Date;
        userId: number;
        user: {
            id: number;
            name: string;
            avatar: string;
        };
    }[]>;
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
        createdAt: Date;
        userId: number;
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
        createdAt: Date;
        userId: number;
        novelId: number;
        content: string;
        score: number;
    }>;
}
