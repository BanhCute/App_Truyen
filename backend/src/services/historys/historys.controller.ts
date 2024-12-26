import {
  Controller,
  Get,
  Post,
  Body,
  Delete,
  Param,
  ParseIntPipe,
  Req,
} from '@nestjs/common';
import { HistorysService } from './historys.service';
import { CreateHistoryDto } from './dto/create-history.dto';
import HistoryDto from './dto/history.dto';
import { plainToInstance } from 'class-transformer';
import { ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { getSession } from '../auth/auth.utils';

@ApiTags('history')
@Controller('history')
export class HistorysController {
  constructor(private readonly historysService: HistorysService) {}

  @Post()
  create(@Body() createHistoryDto: CreateHistoryDto, @Req() req: Request) {
    const session = getSession(req);
    return plainToInstance(
      HistoryDto,
      this.historysService.create(createHistoryDto, session.id),
    );
  }

  @Get()
  findAll() {
    return this.historysService
      .findAll()
      .then((items) => items.map((item) => plainToInstance(HistoryDto, item)));
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(HistoryDto, this.historysService.findOne(id));
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
    const session = getSession(req);
    return plainToInstance(HistoryDto, this.historysService.remove(id, session.id));
  }
}
