import { ApiProperty } from '@nestjs/swagger';
import { IsNumber } from 'class-validator';

export class CreateFollowDto {
  @ApiProperty({ example: 1, description: 'ID của novel muốn follow' })
  @IsNumber({}, { message: 'Novel ID phải là số' })
  novelId: number;
}
