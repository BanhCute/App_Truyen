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

  async findAll() {
    try {
      console.log('Finding all ratings');

      // Get all ratings with user and novel info
      const [ratings, total] = await Promise.all([
        this.databaseService.rating.findMany({
          include: {
            user: {
              select: {
                id: true,
                name: true,
                avatar: true,
              },
            },
            novel: {
              select: {
                id: true,
                name: true,
                cover: true,
              },
            },
          },
          orderBy: {
            createdAt: 'desc',
          },
        }),
        this.databaseService.rating.count(),
      ]);

      console.log(`Found ${ratings.length} ratings (total: ${total})`);
      console.log('Raw ratings:', JSON.stringify(ratings, null, 2));

      // Transform ratings
      const transformedRatings = ratings.map((rating) => ({
        id: rating.id,
        novelId: rating.novelId,
        userId: rating.userId,
        content: rating.content,
        score: rating.score,
        createdAt: rating.createdAt,
        user: rating.user
          ? {
              id: rating.user.id,
              name: rating.user.name || 'Người dùng',
              avatar: rating.user.avatar || 'default-avatar.png',
            }
          : {
              id: rating.userId,
              name: 'Người dùng',
              avatar: 'default-avatar.png',
            },
        novel: rating.novel
          ? {
              id: rating.novel.id,
              name: rating.novel.name,
              cover: rating.novel.cover,
            }
          : null,
      }));

      return {
        items: transformedRatings,
        meta: {
          total,
          page: 1,
          limit: total,
          totalPages: 1,
        },
      };
    } catch (error) {
      console.error('Error finding all ratings:', error);
      console.error('Error details:', error.message);
      console.error('Error stack:', error.stack);
      return {
        items: [],
        meta: {
          total: 0,
          page: 1,
          limit: 10,
          totalPages: 0,
        },
      };
    }
  }

  async findAllByNovelWithUser(novelId: number, page = 1, limit = 10) {
    console.log(
      `Finding ratings for novel ${novelId} in database (page ${page}, limit ${limit})`,
    );

    try {
      const skip = (page - 1) * limit;

      // Get ratings with user info
      const [ratings, total] = await Promise.all([
        this.databaseService.rating.findMany({
          where: {
            novelId: novelId,
          },
      include: {
            user: {
              select: {
                id: true,
                name: true,
                avatar: true,
              },
            },
            novel: {
              select: {
                id: true,
                name: true,
                cover: true,
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
          },
        }),
      ]);

      console.log('Raw database result:', JSON.stringify(ratings, null, 2));
      console.log(`Found ${ratings.length} ratings (total: ${total})`);

      // Transform ratings
      const transformedRatings = ratings.map((rating) => ({
        id: rating.id,
        novelId: rating.novelId,
        userId: rating.userId,
        content: rating.content,
        score: rating.score,
        createdAt: rating.createdAt,
        user: rating.user
          ? {
              id: rating.user.id,
              name: rating.user.name || 'Người dùng',
              avatar: rating.user.avatar || 'default-avatar.png',
            }
          : {
              id: rating.userId,
              name: 'Người dùng',
              avatar: 'default-avatar.png',
            },
        novel: rating.novel
          ? {
              id: rating.novel.id,
              name: rating.novel.name,
              cover: rating.novel.cover,
            }
          : null,
      }));

      return {
        items: transformedRatings,
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
      };
    } catch (error) {
      console.error('Error finding ratings:', error);
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
