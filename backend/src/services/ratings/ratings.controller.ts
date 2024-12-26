import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  ParseIntPipe,
  Req,
} from '@nestjs/common';
import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import RatingDto from './dto/rating.dto';
import { plainToInstance } from 'class-transformer';
import { ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { getSession } from '../auth/auth.utils';

@ApiTags('ratings')
@Controller('ratings')
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Post()
  create(@Body() createRatingDto: CreateRatingDto, @Req() req: Request) {
    const session = getSession(req);
    return plainToInstance(
      RatingDto,
      this.ratingsService.create(createRatingDto, session.id),
    );
  }

  @Get()
  findAll() {
    return this.ratingsService
      .findAll()
      .then((items) => items.map((item) => plainToInstance(RatingDto, item)));
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(RatingDto, this.ratingsService.findOne(id));
  }
}
