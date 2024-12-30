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
  Query,
  DefaultValuePipe,
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
  async findAll(
    @Query('novelId', new DefaultValuePipe(0), ParseIntPipe) novelId: number,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ) {
    console.log(
      `Finding ratings with novelId: ${novelId}, page: ${page}, limit: ${limit}`,
    );
    if (novelId > 0) {
      const result = await this.ratingsService.findAllByNovelWithUser(
        novelId,
        page,
        limit,
      );
      console.log('Found ratings:', JSON.stringify(result.items, null, 2));
      return result.items;
    }
    return this.ratingsService.findAll();
  }

  @Get('novel/:novelId/with-user')
  async findAllByNovelWithUser(
    @Param('novelId', ParseIntPipe) novelId: number,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ) {
    console.log(
      `Finding ratings for novel ${novelId} (page ${page}, limit ${limit})`,
    );
    const result = await this.ratingsService.findAllByNovelWithUser(
      novelId,
      page,
      limit,
    );
    console.log('Found ratings:', JSON.stringify(result, null, 2));
    return result;
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
