import { PartialType } from '@nestjs/mapped-types';
import { CreateNovelDto } from './create-novel.dto';

export class UpdateNovelDto extends PartialType(CreateNovelDto) {
  id?: number;
  createdAt?: Date;
  updatedAt?: Date;
  view?: number;
  rating?: number;
  followerCount?: number;
  commentCount?: number;
}
