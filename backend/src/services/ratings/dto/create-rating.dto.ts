import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsString, Min, Max, IsNotEmpty } from 'class-validator';

export class CreateRatingDto {
  @ApiProperty({ example: 1, description: 'ID của novel muốn đánh giá' })
  @IsNumber({}, { message: 'Novel ID phải là số' })
  novelId: number;

  @ApiProperty({ example: 'Truyện rất hay!', description: 'Nội dung đánh giá' })
  @IsString({ message: 'Nội dung phải là chuỗi' })
  @IsNotEmpty({ message: 'Nội dung không được để trống' })
  content: string;

  @ApiProperty({ example: 5, description: 'Điểm đánh giá (0-5)' })
  @IsNumber({}, { message: 'Điểm đánh giá phải là số' })
  @Min(0, { message: 'Điểm đánh giá phải từ 0-5 sao' })
  @Max(5, { message: 'Điểm đánh giá phải từ 0-5 sao' })
  score: number;
}
