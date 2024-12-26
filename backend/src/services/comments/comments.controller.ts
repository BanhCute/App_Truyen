import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
  BadRequestException,
  Req,
} from '@nestjs/common';
import { CommentsService } from './comments.service';
import { CreateCommentDto } from './dto/create-comment.dto';
import { UpdateCommentDto } from './dto/update-comment.dto';
import CommentDto from './dto/comments.dto';
import { plainToInstance } from 'class-transformer';
import { getSession } from '../auth/auth.utils';
import { Request } from 'express';

@Controller('comments')
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Post()
  async create(
    @Body() createCommentDto: CreateCommentDto,
    @Req() req: Request,
  ) {
    const session = getSession(req);
    return plainToInstance(
      CommentDto,
      this.commentsService.create(createCommentDto, session.id),
    );
  }

  @Get()
  async findAll() {
    const comments = await this.commentsService.findAll();
    return Array.isArray(comments)
      ? comments.map((item) => plainToInstance(CommentDto, item))
      : [];
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(CommentDto, this.commentsService.findOne(id));
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: Request) {
    const session = getSession(req);
    try {
      return await this.commentsService.remove(id, session.id);
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw new BadRequestException(
          'Không được phép xóa comment sau khi đã đăng',
        );
      }
      throw error;
    }
  }
}
