import { CreateNovelDto } from './create-novel.dto';
declare const UpdateNovelDto_base: import("@nestjs/mapped-types").MappedType<Partial<CreateNovelDto>>;
export declare class UpdateNovelDto extends UpdateNovelDto_base {
    id?: number;
    createdAt?: Date;
    updatedAt?: Date;
    view?: number;
    rating?: number;
    followerCount?: number;
    commentCount?: number;
}
export {};
