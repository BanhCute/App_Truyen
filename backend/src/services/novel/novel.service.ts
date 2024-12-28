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
        categories: {
          include: {
            category: true,
          },
        },
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
        categories: {
          include: {
            category: true,
          },
        },
      },
    });
  }

  async update(id: number, updateNovelDto: UpdateNovelDto, userId: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
    });

    if (!novel) {
      throw new NotFoundException('Không tìm thấy truyện');
    }

    if (novel.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền cập nhật truyện này');
    }

    return this.databaseService.novel.update({
      where: { id },
      data: updateNovelDto,
    });
  }

  async remove(id: number, userId: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
    });

    if (!novel) {
      throw new NotFoundException('Không tìm thấy truyện');
    }

    if (novel.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền xóa truyện này');
    }

    return this.databaseService.novel.delete({
      where: { id },
    });
  }

  async addCategories(id: number, categoryIds: number[], userId: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
      include: {
        categories: true,
      },
    });

    if (!novel) {
      throw new NotFoundException('Không tìm thấy truyện');
    }

    if (novel.userId !== userId) {
      throw new ForbiddenException(
        'Bạn không có quyền thêm thể loại cho truyện này',
      );
    }

    // Kiểm tra các thể loại tồn tại
    const categories = await this.databaseService.category.findMany({
      where: {
        id: {
          in: categoryIds,
        },
      },
    });

    if (categories.length !== categoryIds.length) {
      throw new BadRequestException('Một số thể loại không tồn tại');
    }

    // Thêm các thể loại mới
    const existingCategoryIds = novel.categories.map((nc) => nc.categoryId);
    const newCategoryIds = categoryIds.filter(
      (id) => !existingCategoryIds.includes(id),
    );

    await this.databaseService.novelCategory.createMany({
      data: newCategoryIds.map((categoryId) => ({
        novelId: id,
        categoryId,
      })),
      skipDuplicates: true,
    });

    return this.databaseService.novel.findUnique({
      where: { id },
      include: {
        categories: {
          include: {
            category: true,
          },
        },
      },
    });
  }

  async removeCategory(id: number, categoryId: number, userId: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
    });

    if (!novel) {
      throw new NotFoundException('Không tìm thấy truyện');
    }

    if (novel.userId !== userId) {
      throw new ForbiddenException(
        'Bạn không có quyền xóa thể loại của truyện này',
      );
    }

    await this.databaseService.novelCategory.delete({
      where: {
        novelId_categoryId: {
          novelId: id,
          categoryId,
        },
      },
    });

    return this.databaseService.novel.findUnique({
      where: { id },
      include: {
        categories: {
          include: {
            category: true,
          },
        },
      },
    });
  }
}
