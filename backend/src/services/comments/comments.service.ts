import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { CreateCommentDto } from './dto/create-comment.dto';
import { UpdateCommentDto } from './dto/update-comment.dto';
import { DatabaseService } from 'src/services/database/database.service';

@Injectable()
export class CommentsService {
  constructor(private readonly databaseService: DatabaseService) {}

  async create(createCommentDto: CreateCommentDto, userId: number) {
    const { chapterId, content, novelId } = createCommentDto;

    // Chỉ kiểm tra độ dài nội dung
    const trimmedContent = content.trim();
    if (trimmedContent.length === 0) {
      throw new BadRequestException('Nội dung comment không được để trống');
    }

    // Kiểm tra chapter tồn tại
    const chapter = await this.databaseService.chapter.findUnique({
      where: { id: chapterId },
    });

    if (!chapter) {
      throw new NotFoundException(`Chapter với ID ${chapterId} không tồn tại`);
    }

    // Tạo comment mới với userId mặc định là 0 (hoặc giá trị từ request.user)
    return this.databaseService.comment.create({
      data: {
        content: trimmedContent,
        userId: userId,
        chapterId,
        novelId,
      },
      include: {
        user: true,
        chapter: true,
      },
    });
  }

  async findAll() {
    return this.databaseService.comment.findMany({
      include: {
        chapter: true,
        user: true,
        Novel: true,
      },
    });
  }

  findOne(id: number) {
    return this.databaseService.comment.findUnique({
      where: { id },
      include: {
        chapter: true,
        user: true,
        Novel: true,
      },
    });
  }

  async update(id: number, updateCommentDto: UpdateCommentDto) {
    const comment = await this.databaseService.comment.findUnique({
      where: { id },
    });

    if (!comment) {
      throw new NotFoundException(`Comment với ID ${id} không tồn tại`);
    }

    // Luôn throw lỗi khi có người cố gắng sửa comment
    throw new BadRequestException(
      'Không được phép sửa comment sau khi đã đăng',
    );
  }

  async remove(id: number, userId: number) {
    const comment = await this.databaseService.comment.findUnique({
      where: { id },
    });

    if (!comment) {
      throw new NotFoundException(`Comment với ID ${id} không tồn tại`);
    }

    if (comment.userId !== userId) {
      throw new ForbiddenException('Bạn không có quyền xóa comment này');
    }

    return this.databaseService.comment.delete({
      where: { id },
    });
  }
}
