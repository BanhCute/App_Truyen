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
exports.NovelService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../database/database.service");
let NovelService = class NovelService {
    constructor(databaseService) {
        this.databaseService = databaseService;
    }
    async create(createNovelDto, userId) {
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
            },
        });
    }
    findOne(id) {
        return this.databaseService.novel.findUnique({
            where: { id },
            include: {
                user: true,
                chapters: true,
                comments: true,
                ratings: true,
            },
        });
    }
    async update(id, updateNovelDto, userId) {
        const novel = await this.findOne(id);
        if (novel.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền sửa novel này');
        }
        try {
            const currentNovel = await this.databaseService.novel.findUnique({
                where: { id },
            });
            if (!currentNovel) {
                throw new common_1.NotFoundException(`Novel với ID ${id} không tồn tại`);
            }
            if (updateNovelDto.id && updateNovelDto.id !== currentNovel.id) {
                throw new common_1.BadRequestException('Bạn không được phép sửa ID của truyện');
            }
            if ('createdAt' in updateNovelDto) {
                const currentDate = new Date(currentNovel.createdAt).getTime();
                const updateDate = new Date(updateNovelDto.createdAt).getTime();
                if (currentDate !== updateDate) {
                    throw new common_1.BadRequestException('Bạn không được phép sửa ngày tạo của truyện');
                }
            }
            if ('view' in updateNovelDto &&
                updateNovelDto.view !== currentNovel.view) {
                throw new common_1.BadRequestException('Bạn không được phép sửa số lượt xem của truyện');
            }
            if ('updatedAt' in updateNovelDto) {
                const currentDate = new Date(currentNovel.updatedAt).getTime();
                const updateDate = new Date(updateNovelDto.updatedAt).getTime();
                if (currentDate !== updateDate) {
                    throw new common_1.BadRequestException('Bạn không được phép sửa ngày cập nhật của truyện');
                }
            }
            if ('rating' in updateNovelDto &&
                updateNovelDto.rating !== currentNovel.rating) {
                throw new common_1.BadRequestException('Bạn không được phép sửa điểm đánh giá của truyện');
            }
            if ('followerCount' in updateNovelDto &&
                updateNovelDto.followerCount !== currentNovel.followerCount) {
                throw new common_1.BadRequestException('Bạn không được phép sửa số người theo dõi truyện');
            }
            if ('commentCount' in updateNovelDto &&
                updateNovelDto.commentCount !== currentNovel.commentCount) {
                throw new common_1.BadRequestException('Bạn không được phép sửa số lượng bình luận');
            }
            return await this.databaseService.novel.update({
                where: { id },
                data: updateNovelDto,
            });
        }
        catch (error) {
            if (error instanceof common_1.BadRequestException ||
                error instanceof common_1.NotFoundException) {
                throw error;
            }
            throw new common_1.BadRequestException('Không thể sửa UserId.');
        }
    }
    async remove(id, userId) {
        const novel = await this.findOne(id);
        if (novel.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền xóa novel này');
        }
        return this.databaseService.novel.delete({
            where: { id },
        });
    }
};
exports.NovelService = NovelService;
exports.NovelService = NovelService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], NovelService);
//# sourceMappingURL=novel.service.js.map