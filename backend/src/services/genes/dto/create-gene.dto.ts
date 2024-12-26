import {
  IsString,
  IsNotEmpty,
  IsOptional,
  MinLength,
  MaxLength,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateGeneDto {
  @ApiProperty({ example: 'Isekai', description: 'Tên thể loại' })
  @IsString({ message: 'Tên phải là chuỗi' })
  @IsNotEmpty({ message: 'Tên không được để trống' })
  @MinLength(2, { message: 'Tên phải có ít nhất 2 ký tự' })
  @MaxLength(50, { message: 'Tên không được vượt quá 50 ký tự' })
  name: string;

  @ApiProperty({
    example: 'Thể loại dị giới',
    description: 'Mô tả thể loại',
    required: false,
  })
  @IsString({ message: 'Mô tả phải là chuỗi' })
  @IsOptional()
  @MaxLength(200, { message: 'Mô tả không được vượt quá 200 ký tự' })
  description?: string;
}
