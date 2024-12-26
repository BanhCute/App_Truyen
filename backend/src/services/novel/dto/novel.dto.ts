import { Expose } from 'class-transformer';

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
}
