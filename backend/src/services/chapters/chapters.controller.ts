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
import { ChaptersService } from './chapters.service';
import { CreateChapterDto } from './dto/create-chapter.dto';
import { UpdateChapterDto } from './dto/update-chapter.dto';
import ChapterDto from './dto/chapter.dto';
import { plainToInstance } from 'class-transformer';

@Controller('chapters')
export class ChaptersController {
  constructor(private readonly chaptersService: ChaptersService) {}

  @Post()
  async create(@Body() createChapterDto: CreateChapterDto) {
    const chapter = await this.chaptersService.create(createChapterDto);
    return plainToInstance(ChapterDto, chapter);
  }

  @Get()
  async findAll() {
    const chapters = await this.chaptersService.findAll();
    return chapters.map((chapter) => plainToInstance(ChapterDto, chapter));
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    const chapter = await this.chaptersService.findOne(id);
    return plainToInstance(ChapterDto, chapter);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateChapterDto: UpdateChapterDto,
  ) {
    const chapter = await this.chaptersService.update(id, updateChapterDto);
    return plainToInstance(ChapterDto, chapter);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    const chapter = await this.chaptersService.remove(id);
    return plainToInstance(ChapterDto, chapter);
  }
}
