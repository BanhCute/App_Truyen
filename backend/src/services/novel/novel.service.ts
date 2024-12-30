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
    console.log(`Finding novel with id ${id}`);
    return this.databaseService.novel
      .findUnique({
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
                  description: true,
                },
              },
            },
          },
        },
      })
      .then((novel) => {
        console.log('Found novel:', JSON.stringify(novel, null, 2));
        return novel;
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
    console.log(`Adding categories ${categoryIds} to novel ${id}`);
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

    console.log('Current novel categories:', novel?.categories);

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

    console.log('Found categories:', categories);

    if (categories.length !== categoryIds.length) {
      throw new BadRequestException('Một số thể loại không tồn tại');
    }

    // Xóa tất cả các thể loại cũ
    console.log('Deleting old categories...');
    await this.databaseService.novelCategory.deleteMany({
      where: {
        novelId: id,
      },
    });

    // Thêm các thể loại mới
    console.log('Adding new categories...');
    await this.databaseService.novelCategory.createMany({
      data: categoryIds.map((categoryId) => ({
        novelId: id,
        categoryId,
      })),
    });

    // Trả về novel với thông tin categories đã cập nhật
    const updatedNovel = await this.databaseService.novel.findUnique({
      where: { id },
      include: {
        categories: {
          include: {
            category: true,
          },
        },
      },
    });

    console.log('Updated novel categories:', updatedNovel?.categories);
    return updatedNovel;
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

  async getNovelRatings(id: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
      include: {
        ratings: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                avatar: true,
              },
            },
          },
          orderBy: {
            createdAt: 'desc',
          },
        },
      },
    });

    if (!novel) {
      throw new NotFoundException('Không tìm thấy truyện');
    }

    return novel.ratings;
  }

  async getAverageRating(id: number) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
      include: {
        ratings: true,
      },
    });

    if (!novel) {
      throw new NotFoundException('Không tìm thấy truyện');
    }

    if (novel.ratings.length === 0) {
      return { average: 0 };
    }

    const sum = novel.ratings.reduce((acc, rating) => acc + rating.score, 0);
    const average = sum / novel.ratings.length;

    return { average };
  }

  async rateNovel(
    id: number,
    userId: number,
    ratingData: { score: number; content: string },
  ) {
    const novel = await this.databaseService.novel.findUnique({
      where: { id },
    });

    if (!novel) {
      throw new NotFoundException('Không tìm thấy truyện');
    }

    // Kiểm tra xem người dùng đã đánh giá chưa
    const existingRating = await this.databaseService.rating.findFirst({
      where: {
        novelId: id,
        userId: userId,
      },
    });

    if (existingRating) {
      throw new BadRequestException('Bạn đã đánh giá truyện này rồi');
    }

    // Validate score
    if (ratingData.score < 1 || ratingData.score > 5) {
      throw new BadRequestException('Điểm đánh giá phải từ 1 đến 5');
    }

    // Tạo đánh giá mới
    const rating = await this.databaseService.rating.create({
      data: {
        novelId: id,
        userId: userId,
        score: ratingData.score,
        content: ratingData.content,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    // Cập nhật điểm trung bình của truyện
    const ratings = await this.databaseService.rating.findMany({
      where: { novelId: id },
    });

    const sum = ratings.reduce((acc, rating) => acc + rating.score, 0);
    const average = sum / ratings.length;

    await this.databaseService.novel.update({
      where: { id },
      data: {
        rating: average,
      },
    });

    return rating;
  }

  async updateRating(
    novelId: number,
    ratingId: number,
    userId: number,
    ratingData: { score: number; content: string },
  ) {
    const rating = await this.databaseService.rating.findUnique({
      where: { id: ratingId },
    });

    if (!rating) {
      throw new NotFoundException('Không tìm thấy đánh giá');
    }

    if (rating.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền sửa đánh giá này');
    }

    // Validate score
    if (ratingData.score < 1 || ratingData.score > 5) {
      throw new BadRequestException('Điểm đánh giá phải từ 1 đến 5');
    }

    // Cập nhật đánh giá
    const updatedRating = await this.databaseService.rating.update({
      where: { id: ratingId },
      data: {
        score: ratingData.score,
        content: ratingData.content,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    // Cập nhật điểm trung bình của truyện
    const ratings = await this.databaseService.rating.findMany({
      where: { novelId },
    });

    const sum = ratings.reduce((acc, rating) => acc + rating.score, 0);
    const average = sum / ratings.length;

    await this.databaseService.novel.update({
      where: { id: novelId },
      data: {
        rating: average,
      },
    });

    return updatedRating;
  }
}
