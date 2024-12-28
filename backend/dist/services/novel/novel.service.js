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
    findOne(id) {
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
    async update(id, updateNovelDto, userId) {
        const novel = await this.databaseService.novel.findUnique({
            where: { id },
            select: {
                id: true,
                userId: true,
            },
        });
        if (!novel) {
            throw new common_1.NotFoundException('Không tìm thấy truyện');
        }
        if (novel.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền cập nhật truyện này');
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
    async remove(id, userId) {
        const novel = await this.databaseService.novel.findUnique({
            where: { id },
            select: {
                id: true,
                userId: true,
            },
        });
        if (!novel) {
            throw new common_1.NotFoundException('Không tìm thấy truyện');
        }
        if (novel.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền xóa truyện này');
        }
        return this.databaseService.novel.delete({
            where: { id },
            select: {
                id: true,
            },
        });
    }
    async addCategories(id, categoryIds, userId) {
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
            throw new common_1.NotFoundException('Không tìm thấy truyện');
        }
        if (novel.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền thêm thể loại cho truyện này');
        }
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
            throw new common_1.BadRequestException('Một số thể loại không tồn tại');
        }
        const existingCategoryIds = novel.categories.map((nc) => nc.categoryId);
        const newCategoryIds = categoryIds.filter((id) => !existingCategoryIds.includes(id));
        await this.databaseService.novelCategory.createMany({
            data: newCategoryIds.map((categoryId) => ({
                novelId: id,
                categoryId,
            })),
            skipDuplicates: true,
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
    async removeCategory(id, categoryId, userId) {
        const novel = await this.databaseService.novel.findUnique({
            where: { id },
            select: {
                id: true,
                userId: true,
            },
        });
        if (!novel) {
            throw new common_1.NotFoundException('Không tìm thấy truyện');
        }
        if (novel.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền xóa thể loại của truyện này');
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
};
exports.NovelService = NovelService;
exports.NovelService = NovelService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], NovelService);
//# sourceMappingURL=novel.service.js.map