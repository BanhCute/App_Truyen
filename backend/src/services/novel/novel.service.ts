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
      select: {
        id: true,
        name: true,
        description: true,
        author: true,
        cover: true,
        status: true,
        view: true,
        rating: true,
        followerCount: true,
        commentCount: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
      },
    });
  }

  findAll() {
    return this.databaseService.novel.findMany({
      select: {
        id: true,
        name: true,
        description: true,
        author: true,
        cover: true,
        status: true,
        view: true,
        rating: true,
        followerCount: true,
        commentCount: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        categories: {
          select: {
            category: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });
  }

  findOne(id: number) {
    return this.databaseService.novel.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        description: true,
        author: true,
        cover: true,
        status: true,
        view: true,
        rating: true,
        followerCount: true,
        commentCount: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        categories: {
          select: {
            category: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });
  }

  async update(id: number, updateNovelDto: UpdateNovelDto, userId: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
      select: {
        id: true,
        userId: true,
      },
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
      select: {
        id: true,
        name: true,
        description: true,
        author: true,
        cover: true,
        status: true,
        view: true,
        rating: true,
        followerCount: true,
        commentCount: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
      },
    });
  }

  async remove(id: number, userId: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
      select: {
        id: true,
        userId: true,
      },
    });

    if (!novel) {
      throw new NotFoundException('Không tìm thấy truyện');
    }

    if (novel.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền xóa truyện này');
    }

    return this.databaseService.novel.delete({
      where: { id },
      select: {
        id: true,
      },
    });
  }

  async addCategories(id: number, categoryIds: number[], userId: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
      select: {
        id: true,
        userId: true,
        categories: {
          select: {
            categoryId: true,
          },
        },
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
      select: {
        id: true,
      },
    });

    if (categories.length !== categoryIds.length) {
      throw new BadRequestException('Một số thể loại không tồn tại');
    }

    // Xóa tất cả các thể loại cũ
    await this.databaseService.novelCategory.deleteMany({
      where: {
        novelId: id,
      },
    });

    // Thêm các thể loại mới
    await this.databaseService.novelCategory.createMany({
      data: categoryIds.map((categoryId) => ({
        novelId: id,
        categoryId,
      })),
    });

    // Trả về novel với thông tin categories đã cập nhật
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
      select: {
        id: true,
        userId: true,
      },
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
      select: {
        id: true,
        categories: {
          select: {
            category: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });
  }
}
