import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
  Req,
} from '@nestjs/common';
import { NovelService } from './novel.service';
import { CreateNovelDto } from './dto/create-novel.dto';
import { UpdateNovelDto } from './dto/update-novel.dto';
import NovelDto from './dto/novel.dto';
import { plainToClass, plainToInstance } from 'class-transformer';
import { getSession } from '../auth/auth.utils';
import { Request } from 'express';

@Controller('novels')
export class NovelController {
  constructor(private readonly novelService: NovelService) {}

  @Post()
  create(@Body() createNovelDto: CreateNovelDto, @Req() req: Request) {
    const session = getSession(req);
    return plainToInstance(
      NovelDto,
      this.novelService.create(
        plainToClass(CreateNovelDto, createNovelDto, {
          strategy: 'excludeAll',
        }),
        session.id,
      ),
    );
  }

  @Get()
  async findAll() {
    const data = await this.novelService
      .findAll()
      .then((items) => items.map((item) => plainToInstance(NovelDto, item)));

    return data;
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(NovelDto, this.novelService.findOne(id));
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateNovelDto: UpdateNovelDto,
    @Req() req: Request,
  ) {
    const session = getSession(req);
    return plainToInstance(
      NovelDto,
      this.novelService.update(id, updateNovelDto, session.id),
    );
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
    const session = getSession(req);
    return plainToInstance(NovelDto, this.novelService.remove(id, session.id));
  }

  @Post(':id/categories')
  async addCategories(
    @Param('id', ParseIntPipe) id: number,
    @Body('categoryIds') categoryIds: number[],
    @Req() req: Request,
  ) {
    const session = getSession(req);
    return this.novelService.addCategories(id, categoryIds, session.id);
  }

  @Delete(':id/categories/:categoryId')
  async removeCategory(
    @Param('id', ParseIntPipe) id: number,
    @Param('categoryId', ParseIntPipe) categoryId: number,
    @Req() req: Request,
  ) {
    const session = getSession(req);
    return this.novelService.removeCategory(id, categoryId, session.id);
  }
}
