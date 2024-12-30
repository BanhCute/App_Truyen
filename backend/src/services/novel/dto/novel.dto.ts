import { Expose, Transform } from 'class-transformer';

export default class NovelDto {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  description: string;

  @Expose()
  cover: string;

  @Expose()
  author: string;

  @Expose()
  status: string;

  @Expose()
  view: number;

  @Expose()
  rating: number;

  @Expose()
  followerCount: number;

  @Expose()
  commentCount: number;

  @Expose()
  createdAt: Date;

  @Expose()
  updatedAt: Date;

  @Expose()
  userId: number;

  @Expose()
  categories: {
    category: {
      id: number;
      name: string;
      description: string;
    };
  }[];
}
