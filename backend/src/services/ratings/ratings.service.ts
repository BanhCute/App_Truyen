import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import { UpdateRatingDto } from './dto/update-rating.dto';

@Injectable()
export class RatingsService {
  constructor(private readonly databaseService: DatabaseService) {}

  async create(createRatingDto: CreateRatingDto, userId: number) {
    // Kiểm tra novel tồn tại
    const novel = await this.databaseService.novel.findUnique({
      where: { id: createRatingDto.novelId },
    });

    if (!novel) {
      throw new NotFoundException(
        `Novel với ID ${createRatingDto.novelId} không tồn tại`,
      );
    }

    // Kiểm tra xem đã đánh giá chưa
    const existingRating = await this.databaseService.rating.findFirst({
      where: {
        novelId: createRatingDto.novelId,
        userId: userId,
      },
    });

    if (existingRating) {
      throw new BadRequestException(
        'Bạn đã đánh giá truyện này rồi và không thể đánh giá lại',
      );
    }

    return this.databaseService.rating.create({
      data: {
        novelId: createRatingDto.novelId,
        userId: userId,
        content: createRatingDto.content.trim(),
        score: createRatingDto.score,
        createdAt: new Date(),
      },
      include: {
        novel: true,
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });
  }

  findAll() {
    return this.databaseService.rating.findMany({
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
      where: {
        user: {
          isDeleted: false,
          isBanned: false,
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findAllByNovelWithUser(novelId: number, page = 1, limit = 10) {
    console.log(
      `Finding ratings for novel ${novelId} in database (page ${page}, limit ${limit})`,
    );

    const skip = (page - 1) * limit;

    const [ratings, total] = await Promise.all([
      this.databaseService.rating.findMany({
        where: {
          novelId: novelId,
          user: {
            isDeleted: false,
            isBanned: false,
          },
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
        orderBy: {
          createdAt: 'desc',
        },
        skip,
        take: limit,
      }),
      this.databaseService.rating.count({
        where: {
          novelId: novelId,
          user: {
            isDeleted: false,
            isBanned: false,
          },
        },
      }),
    ]);

    console.log(`Found ${ratings.length} ratings (total: ${total})`);

    return {
      items: ratings,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: number) {
    const rating = await this.databaseService.rating.findUnique({
      where: { id },
      include: {
        novel: true,
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    if (!rating) {
      throw new NotFoundException(`Rating với ID ${id} không tồn tại`);
    }

    return rating;
  }

  async update(id: number, updateRatingDto: UpdateRatingDto, userId: number) {
    // Kiểm tra rating tồn tại
    const rating = await this.databaseService.rating.findUnique({
      where: { id },
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

    if (!rating) {
      throw new NotFoundException(`Rating với ID ${id} không tồn tại`);
    }

    // Kiểm tra quyền update
    if (rating.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền sửa đánh giá này');
    }

    // Update rating
    return this.databaseService.rating.update({
      where: { id },
      data: {
        content: updateRatingDto.content.trim(),
        score: updateRatingDto.score,
      },
      include: {
        novel: true,
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });
  }
}
