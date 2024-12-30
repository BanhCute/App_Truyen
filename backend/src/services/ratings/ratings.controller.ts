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
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Post()
  async create(@Body() createRatingDto: CreateRatingDto, @Req() req: Request) {
    const session = getSession(req);
    const rating = await this.ratingsService.create(
      createRatingDto,
      session.id,
    );
    return plainToInstance(RatingDto, rating);
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

      const transformedItems = result.items.map((item) => ({
        id: item.id,
        novelId: item.novelId,
        userId: item.userId,
        content: item.content,
        score: item.score,
        createdAt: item.createdAt,
        user: item.user
          ? {
              id: item.user.id,
              name: item.user.name || 'Người dùng',
              avatar: item.user.avatar || 'default-avatar.png',
            }
          : {
              id: item.userId,
              name: 'Người dùng',
              avatar: 'default-avatar.png',
            },
        novel: item.novel
          ? {
              id: item.novel.id,
              name: item.novel.name,
              cover: item.novel.cover,
            }
          : null,
      }));

      console.log(
        'Transformed items:',
        JSON.stringify(transformedItems, null, 2),
      );

      return {
        items: transformedItems,
        meta: result.meta,
      };
    } catch (error) {
      console.error('Error in findAll:', error);
      console.error('Error details:', error.message);
      console.error('Error stack:', error.stack);
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

      console.log('Raw result:', JSON.stringify(result, null, 2));

      const transformedItems = result.items.map((item) =>
        plainToInstance(RatingDto, item),
      );

      console.log(
        'Transformed items:',
        JSON.stringify(transformedItems, null, 2),
      );

      return {
        items: transformedItems,
        meta: result.meta,
      };
    } catch (error) {
      console.error('Error in findAllByNovelWithUser:', error);
      console.error('Error details:', error.message);
      console.error('Error stack:', error.stack);
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
    return plainToInstance(RatingDto, rating);
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
    return plainToInstance(RatingDto, rating);
  }
}
