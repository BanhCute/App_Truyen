import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  ParseIntPipe,
  Req,
  Put,
  ClassSerializerInterceptor,
  UseInterceptors,
} from '@nestjs/common';
import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import RatingDto from './dto/rating.dto';
import { plainToInstance } from 'class-transformer';
import { ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { getSession } from '../auth/auth.utils';
import { UpdateRatingDto } from './dto/update-rating.dto';

@ApiTags('ratings')
@Controller('ratings')
@UseInterceptors(ClassSerializerInterceptor)
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Post()
  create(@Body() createRatingDto: CreateRatingDto, @Req() req: Request) {
    const session = getSession(req);
    return this.ratingsService.create(createRatingDto, session.id);
  }

  @Get()
  findAll() {
    return this.ratingsService.findAll();
  }

  @Get('novel/:novelId/with-user')
  findAllByNovelWithUser(@Param('novelId', ParseIntPipe) novelId: number) {
    return this.ratingsService.findAllByNovelWithUser(novelId);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.ratingsService.findOne(id);
  }

  @Put(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateRatingDto: UpdateRatingDto,
    @Req() req: Request,
  ) {
    const session = getSession(req);
    return this.ratingsService.update(id, updateRatingDto, session.id);
  }
}
