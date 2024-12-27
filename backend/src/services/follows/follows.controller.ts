import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  ParseIntPipe,
  Req,
  UseGuards,
} from '@nestjs/common';
import { FollowsService } from './follows.service';
import { CreateFollowDto } from './dto/create-follow.dto';
import FollowDto from './dto/follows.dto';
import { plainToInstance } from 'class-transformer';
import { ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { getSession } from '../auth/auth.utils';
import { AuthGuard } from '../auth/auth.guard';

@ApiTags('follows')
@Controller('follows')
@UseGuards(AuthGuard)
export class FollowsController {
  constructor(private readonly followsService: FollowsService) {}

  @Post()
  create(@Body() createFollowDto: CreateFollowDto, @Req() req: Request) {
    const session = getSession(req);
    return plainToInstance(
      FollowDto,
      this.followsService.create(createFollowDto, session.id),
    );
  }

  @Get()
  findAll(@Req() req: Request) {
    const session = getSession(req);
    return this.followsService
      .findAll(session.id)
      .then((items) => items.map((item) => plainToInstance(FollowDto, item)));
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(FollowDto, this.followsService.findOne(id));
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
    const session = getSession(req);
    return plainToInstance(
      FollowDto,
      this.followsService.remove(id, session.id),
    );
  }

  @Delete('novel/:novelId')
  async removeByNovelId(
    @Param('novelId', ParseIntPipe) novelId: number,
    @Req() req: Request,
  ) {
    const session = getSession(req);
    return plainToInstance(
      FollowDto,
      await this.followsService.removeByNovelId(novelId, session.id),
    );
  }
}
