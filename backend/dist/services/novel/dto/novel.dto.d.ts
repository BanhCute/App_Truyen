export declare class CategoryDto {
    id: number;
    name: string;
}
export declare class NovelCategoryDto {
    category: CategoryDto;
}
export default class NovelDto {
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
    categories: NovelCategoryDto[];
}
