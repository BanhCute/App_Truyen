import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
} from '@nestjs/common';
import { GenesService } from './genes.service';
import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';
import { plainToInstance } from 'class-transformer';
import GeneDto from './dto/gene.dto';

@Controller('genes')
export class GenesController {
  constructor(private readonly genesService: GenesService) {}

  @Post()
  async create(@Body() createGeneDto: CreateGeneDto) {
    try {
      const result = await this.genesService.create(createGeneDto);
      return plainToInstance(GeneDto, result);
    } catch (error) {
      console.log('Error:', error);
      throw error;
    }
  }

  @Get()
  findAll() {
    return this.genesService
      .findAll()
      .then((items) => items.map((item) => plainToInstance(GeneDto, item)));
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(GeneDto, this.genesService.findOne(id));
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateGeneDto: UpdateGeneDto,
  ) {
    return plainToInstance(
      GeneDto,
      this.genesService.update(id, updateGeneDto),
    );
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(GeneDto, this.genesService.remove(id));
  }
}
