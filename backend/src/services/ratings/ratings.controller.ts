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
    try {
      console.log('Request query params:', { novelId, page, limit });

      const result =
        novelId > 0
          ? await this.ratingsService.findAllByNovelWithUser(
              novelId,
              page,
              limit,
            )
          : await this.ratingsService.findAll();

      console.log('Raw result:', JSON.stringify(result, null, 2));

      const transformedRatings = plainToInstance(RatingDto, result.items, {
        excludeExtraneousValues: true,
      });

      return {
        items: transformedRatings,
        meta: result.meta,
      };
    } catch (error) {
      console.error('Error in findAll:', error);
      return {
        items: [],
        meta: {
          page,
          limit,
          total: 0,
          totalPages: 0,
        },
      };
    }
  }

  @Get('novel/:novelId/with-user')
  async findAllByNovelWithUser(
    @Param('novelId', ParseIntPipe) novelId: number,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ) {
    try {
      console.log(
        `Finding ratings for novel ${novelId} (page ${page}, limit ${limit})`,
      );
      const result = await this.ratingsService.findAllByNovelWithUser(
        novelId,
        page,
        limit,
      );
      console.log('Found ratings:', JSON.stringify(result, null, 2));

      const transformedRatings = plainToInstance(RatingDto, result.items, {
        excludeExtraneousValues: true,
      });
      return {
        items: transformedRatings,
        meta: result.meta,
      };
    } catch (error) {
      console.error('Error in findAllByNovelWithUser:', error);
      return {
        items: [],
        meta: {
          page,
          limit,
          total: 0,
          totalPages: 0,
        },
      };
    }
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    const rating = await this.ratingsService.findOne(id);
    return plainToInstance(RatingDto, rating, {
      excludeExtraneousValues: true,
    });
  }

  @Put(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateRatingDto: UpdateRatingDto,
    @Req() req: Request,
  ) {
    const session = getSession(req);
    const rating = await this.ratingsService.update(
      id,
      updateRatingDto,
      session.id,
    );
    return plainToInstance(RatingDto, rating, {
      excludeExtraneousValues: true,
    });
  }
}
