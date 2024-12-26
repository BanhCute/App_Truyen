"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommentsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../database/database.service");
let CommentsService = class CommentsService {
    constructor(databaseService) {
        this.databaseService = databaseService;
    }
    async create(createCommentDto, userId) {
        const { chapterId, content, novelId } = createCommentDto;
        const trimmedContent = content.trim();
        if (trimmedContent.length === 0) {
            throw new common_1.BadRequestException('Nội dung comment không được để trống');
        }
        const chapter = await this.databaseService.chapter.findUnique({
            where: { id: chapterId },
        });
        if (!chapter) {
            throw new common_1.NotFoundException(`Chapter với ID ${chapterId} không tồn tại`);
        }
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
    findOne(id) {
        return this.databaseService.comment.findUnique({
            where: { id },
            include: {
                chapter: true,
                user: true,
                Novel: true,
            },
        });
    }
    async update(id, updateCommentDto) {
        const comment = await this.databaseService.comment.findUnique({
            where: { id },
        });
        if (!comment) {
            throw new common_1.NotFoundException(`Comment với ID ${id} không tồn tại`);
        }
        throw new common_1.BadRequestException('Không được phép sửa comment sau khi đã đăng');
    }
    async remove(id, userId) {
        const comment = await this.databaseService.comment.findUnique({
            where: { id },
        });
        if (!comment) {
            throw new common_1.NotFoundException(`Comment với ID ${id} không tồn tại`);
        }
        if (comment.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền xóa comment này');
        }
        return this.databaseService.comment.delete({
            where: { id },
        });
    }
};
exports.CommentsService = CommentsService;
exports.CommentsService = CommentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], CommentsService);
//# sourceMappingURL=comments.service.js.map