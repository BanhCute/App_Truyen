import { PartialType } from '@nestjs/swagger';
import { CreateGeneDto } from './create-gene.dto';

export class UpdateGeneDto extends PartialType(CreateGeneDto) {}
