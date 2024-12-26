import { Expose } from 'class-transformer';

export default class GeneDto {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  description: string;
}
