import { IsString, IsNotEmpty, IsNumber, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCommentDto {
  @ApiProperty({ example: 1, description: 'ID của chapter' })
  @IsNumber({}, { message: 'Chapter ID phải là số' })
  chapterId: number;

  @ApiProperty({ example: 'Truyện hay quá!', description: 'Nội dung bình luận' })
  @IsString({ message: 'Nội dung phải là chuỗi' })
  @IsNotEmpty({ message: 'Nội dung không được để trống' })
  content: string;

  @ApiProperty({ example: 1, description: 'ID của novel (tùy chọn)', required: false })
  @IsOptional()
  @IsNumber({}, { message: 'Novel ID phải là số' })
  novelId?: number;
}
