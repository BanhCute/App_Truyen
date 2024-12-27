import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateFollowDto } from './dto/create-follow.dto';
import { UpdateFollowDto } from './dto/update-follow.dto';

@Injectable()
export class FollowsService {
  constructor(private readonly databaseService: DatabaseService) {}

  async create(createFollowDto: CreateFollowDto, userId: number) {
    // Kiểm tra novel tồn tại
    const novel = await this.databaseService.novel.findUnique({
      where: { id: createFollowDto.novelId },
    });

    if (!novel) {
      throw new NotFoundException(
        `Novel với ID ${createFollowDto.novelId} không tồn tại`,
      );
    }

    // Kiểm tra xem đã follow chưa
    const existingFollow = await this.databaseService.follow.findFirst({
      where: {
        AND: [{ novelId: createFollowDto.novelId }, { userId: userId }],
      },
    });

    if (existingFollow) {
      throw new BadRequestException('Bạn đã follow truyện này rồi');
    }

    return this.databaseService.follow.create({
      data: {
        novelId: createFollowDto.novelId,
        userId: userId,
        createdAt: new Date(),
      },
    });
  }

  findAll(userId: number) {
    return this.databaseService.follow.findMany({
      where: {
        userId: userId,
      },
      distinct: ['novelId'],
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        novel: true,
      },
    });
  }

  async findOne(id: number) {
    const follow = await this.databaseService.follow.findUnique({
      where: { id },
      include: {
        novel: true,
        user: true,
      },
    });

    if (!follow) {
      throw new NotFoundException(`Follow với ID ${id} không tồn tại`);
    }

    return follow;
  }

  // Không cần phương thức update vì người dùng chỉ cần thêm/xóa follow

  async remove(id: number, userId: number) {
    const follow = await this.databaseService.follow.findUnique({
      where: { id },
    });

    if (!follow) {
      throw new NotFoundException(`Follow với ID ${id} không tồn tại`);
    }

    if (follow.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền xóa follow này');
    }

    return this.databaseService.follow.delete({
      where: { id },
      include: {
        novel: true,
        user: true,
      },
    });
  }

  async removeByNovelId(novelId: number, userId: number) {
    const follow = await this.databaseService.follow.findFirst({
      where: {
        novelId,
        userId,
      },
    });

    if (!follow) {
      throw new NotFoundException('Follow not found');
    }

    return this.databaseService.follow.delete({
      where: {
        id: follow.id,
      },
    });
  }
}
