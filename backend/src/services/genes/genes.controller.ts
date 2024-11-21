import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { GenesService } from './genes.service';
import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';

@Controller('genes')
export class GenesController {
  constructor(private readonly genesService: GenesService) {}

  @Post()
  create(@Body() createGeneDto: CreateGeneDto) {
    return this.genesService.create(createGeneDto);
  }

  @Get()
  findAll() {
    return this.genesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.genesService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateGeneDto: UpdateGeneDto) {
    return this.genesService.update(+id, updateGeneDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.genesService.remove(+id);
  }
}
