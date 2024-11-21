import { Expose } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export default class GeneDto {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  description: string;
}
