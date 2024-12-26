import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateHistoryDto } from './dto/create-history.dto';
import { UpdateHistoryDto } from './dto/update-history.dto';

@Injectable()
export class HistorysService {
  constructor(private readonly databaseService: DatabaseService) {}

  async create(createHistoryDto: CreateHistoryDto, userId: number) {
    // Kiểm tra novel tồn tại
    const novel = await this.databaseService.novel.findUnique({
      where: { id: createHistoryDto.novelId },
    });

    if (!novel) {
      throw new NotFoundException(
        `Novel với ID ${createHistoryDto.novelId} không tồn tại`,
      );
    }

    return this.databaseService.history.create({
      data: {
        novelId: createHistoryDto.novelId,
        userId: userId,
        createdAt: new Date(),
      },
      include: {
        novel: true,
      },
    });
  }

  findAll() {
    return this.databaseService.history.findMany({
      include: {
        novel: true,
      },
    });
  }

  async findOne(id: number) {
    const history = await this.databaseService.history.findUnique({
      where: { id },
      include: {
        novel: true,
      },
    });

    if (!history) {
      throw new NotFoundException(`History với ID ${id} không tồn tại`);
    }

    return history;
  }

  async remove(id: number, userId: number) {
    const history = await this.databaseService.history.findUnique({
      where: { id },
    });

    if (!history) {
      throw new NotFoundException(`History với ID ${id} không tồn tại`);
    }

    if (history.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền xóa history này');
    }

    return this.databaseService.history.delete({
      where: { id },
      include: {
        novel: true,
      },
    });
  }
}
