import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateRatingDto } from './dto/create-rating.dto';

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
        AND: [{ novelId: createRatingDto.novelId }, { userId: userId }],
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
        user: true,
      },
    });
  }

  findAll() {
    return this.databaseService.rating.findMany({
      include: {
        novel: true,
        user: true,
      },
    });
  }

  async findOne(id: number) {
    const rating = await this.databaseService.rating.findUnique({
      where: { id },
      include: {
        novel: true,
        user: true,
      },
    });

    if (!rating) {
      throw new NotFoundException(`Rating với ID ${id} không tồn tại`);
    }

    return rating;
  }
}
