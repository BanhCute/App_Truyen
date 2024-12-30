import { NovelStatus } from '../novel-status.enum';
export declare class CreateNovelDto {
    name: string;
    description?: string;
    cover?: string;
    author: string;
    status: NovelStatus;
}
