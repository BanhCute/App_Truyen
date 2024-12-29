import { Expose, Type } from 'class-transformer';

export class CategoryDto {
  @Expose()
  id: number;

  @Expose()
  name: string;
}

export class NovelCategoryDto {
  @Expose()
  @Type(() => CategoryDto)
  category: CategoryDto;
}

export default class NovelDto {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  description: string;

  @Expose()
  createdAt: Date;

  @Expose()
  cover: string;

  @Expose()
  author: string;

  @Expose()
  status: string;

  @Expose()
  view: number;

  @Expose()
  updatedAt: Date;

  @Expose()
  rating: number;

  @Expose()
  followerCount: number;

  @Expose()
  commentCount: number;

  @Expose()
  userId: number;

  @Expose()
  @Type(() => NovelCategoryDto)
  categories: NovelCategoryDto[];
}
