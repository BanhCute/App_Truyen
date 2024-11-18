import { Expose } from 'class-transformer';

export default class CategoryDto {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  description: string;
}
