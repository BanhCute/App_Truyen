import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, MaxLength, MinLength } from 'class-validator';

export class UpdateProfileDto {
  @ApiProperty({
    minLength: 4,
    maxLength: 40,
  })
  @IsNotEmpty()
  @MinLength(4)
  @MaxLength(40)
  name: string;

  @ApiProperty({
    minLength: 10,
    maxLength: 100,
  })
  @IsNotEmpty()
  @MinLength(10)
  @MaxLength(100)
  about: string;
}
