import {
  IsString,
  IsNotEmpty,
  IsNumber,
  MinLength,
  MaxLength,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateChapterDto {
  @ApiProperty({
    example: 'Chapter 1: Bắt đầu cuộc phiêu lưu',
    description: 'Tên chapter',
  })
  @IsString({ message: 'Tên chapter phải là chuỗi' })
  @IsNotEmpty({ message: 'Tên chapter không được để trống' })
  @MinLength(2, { message: 'Tên chapter phải có ít nhất 2 ký tự' })
  @MaxLength(100, { message: 'Tên chapter không được vượt quá 100 ký tự' })
  name: string;

  @ApiProperty({
    example: 1,
    description: 'ID của novel mà chapter thuộc về',
  })
  @IsNumber({}, { message: 'ID novel phải là số' })
  @IsNotEmpty({ message: 'ID novel không được để trống' })
  novelId: number;

  @ApiProperty({
    description: 'Content của novel mà chapter thuộc về',
  })
  @IsNotEmpty({ message: 'Content novel không được để trống' })
  content: string;
}
