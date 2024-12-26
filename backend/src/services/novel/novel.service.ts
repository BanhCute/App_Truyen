import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { CreateNovelDto } from './dto/create-novel.dto';
import { UpdateNovelDto } from './dto/update-novel.dto';
import { DatabaseService } from 'src/services/database/database.service';

@Injectable()
export class NovelService {
  constructor(private readonly databaseService: DatabaseService) {}

  async create(createNovelDto: CreateNovelDto, userId: number) {
    return this.databaseService.novel.create({
      data: {
        ...createNovelDto,
        userId,
        view: 0,
        rating: 0,
        followerCount: 0,
        commentCount: 0,
      },
    });
  }

  findAll() {
    return this.databaseService.novel.findMany({
      include: {
        user: true,
        
      },
    });
  }

  findOne(id: number) {
    return this.databaseService.novel.findUnique({
      where: { id },
      include: {
        user: true,
        chapters: true,
        comments: true,
        ratings: true,
      },
    });
  }

  async update(id: number, updateNovelDto: UpdateNovelDto, userId: number) {
    const novel = await this.findOne(id);
    if (novel.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền sửa novel này');
    }
    try {
      const currentNovel = await this.databaseService.novel.findUnique({
        where: { id },
      });

      if (!currentNovel) {
        throw new NotFoundException(`Novel với ID ${id} không tồn tại`);
      }

      // Kiểm tra ID
      if (updateNovelDto.id && updateNovelDto.id !== currentNovel.id) {
        throw new BadRequestException('Bạn không được phép sửa ID của truyện');
      }

      // Kiểm tra createdAt
      if ('createdAt' in updateNovelDto) {
        const currentDate = new Date(currentNovel.createdAt).getTime();
        const updateDate = new Date(updateNovelDto.createdAt).getTime();

        if (currentDate !== updateDate) {
          throw new BadRequestException(
            'Bạn không được phép sửa ngày tạo của truyện',
          );
        }
      }

      // Kiểm tra view
      if (
        'view' in updateNovelDto &&
        updateNovelDto.view !== currentNovel.view
      ) {
        throw new BadRequestException(
          'Bạn không được phép sửa số lượt xem của truyện',
        );
      }

      // Kiểm tra updatedAt
      if ('updatedAt' in updateNovelDto) {
        const currentDate = new Date(currentNovel.updatedAt).getTime();
        const updateDate = new Date(updateNovelDto.updatedAt).getTime();

        if (currentDate !== updateDate) {
          throw new BadRequestException(
            'Bạn không được phép sửa ngày cập nhật của truyện',
          );
        }
      }

      // Kiểm tra rating
      if (
        'rating' in updateNovelDto &&
        updateNovelDto.rating !== currentNovel.rating
      ) {
        throw new BadRequestException(
          'Bạn không được phép sửa điểm đánh giá của truyện',
        );
      }

      // Kiểm tra followerCount
      if (
        'followerCount' in updateNovelDto &&
        updateNovelDto.followerCount !== currentNovel.followerCount
      ) {
        throw new BadRequestException(
          'Bạn không được phép sửa số người theo dõi truyện',
        );
      }

      // Kiểm tra commentCount
      if (
        'commentCount' in updateNovelDto &&
        updateNovelDto.commentCount !== currentNovel.commentCount
      ) {
        throw new BadRequestException(
          'Bạn không được phép sửa số lượng bình luận',
        );
      }

      return await this.databaseService.novel.update({
        where: { id },
        data: updateNovelDto,
      });
    } catch (error) {
      if (
        error instanceof BadRequestException ||
        error instanceof NotFoundException
      ) {
        throw error;
      }
      throw new BadRequestException('Không thể sửa UserId.');
    }
  }

  async remove(id: number, userId: number) {
    const novel = await this.findOne(id);
    if (novel.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền xóa novel này');
    }
    return this.databaseService.novel.delete({
      where: { id },
    });
  }
}
