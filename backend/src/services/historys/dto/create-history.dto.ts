import { ApiProperty } from '@nestjs/swagger';
import { IsNumber } from 'class-validator';

export class CreateHistoryDto {
  @ApiProperty({ example: 1, description: 'ID của novel' })
  @IsNumber({}, { message: 'Novel ID phải là số' })
  novelId: number;
}
