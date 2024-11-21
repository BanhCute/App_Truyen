import { Expose } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export default class GeneDto {
    @Expose()
    @ApiProperty()
    id: number;

    @Expose()
    @ApiProperty()
    name: string;

    @Expose()
    @ApiProperty()
    description: string;
}
