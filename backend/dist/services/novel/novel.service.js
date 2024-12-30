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
        console.log(`Finding novel with id ${id}`);
        return this.databaseService.novel
            .findUnique({
            where: { id },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        avatar: true,
                    },
                },
                categories: {
                    include: {
                        category: {
                            select: {
                                id: true,
                                name: true,
                                description: true,
                            },
                        },
                    },
                },
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
        })
            .then((novel) => {
            console.log('Found novel:', JSON.stringify(novel, null, 2));
            if (!novel) {
                return null;
            }
            const transformedCategories = novel.categories.map((nc) => ({
                id: nc.category.id,
                name: nc.category.name,
                description: nc.category.description,
            }));
            const transformedRatings = novel.ratings.map((rating) => ({
                id: rating.id,
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
            }));
            const averageRating = novel.ratings.length > 0
                ? novel.ratings.reduce((acc, r) => acc + r.score, 0) /
                    novel.ratings.length
                : 0;
            return {
                ...novel,
                categories: transformedCategories,
                ratings: transformedRatings,
                averageRating,
            };
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
        console.log('Found categories:', categories);
        if (categories.length !== categoryIds.length) {
            throw new common_1.BadRequestException('Một số thể loại không tồn tại');
        }
        console.log('Deleting old categories...');
        await this.databaseService.novelCategory.deleteMany({
            where: {
                novelId: id,
            },
        });
        console.log('Adding new categories...');
        await this.databaseService.novelCategory.createMany({
            data: categoryIds.map((categoryId) => ({
                novelId: id,
                categoryId,
            })),
        });
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
    async getNovelRatings(id) {
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
            throw new common_1.NotFoundException('Không tìm thấy truyện');
        }
        return novel.ratings;
    }
    async getAverageRating(id) {
        const novel = await this.databaseService.novel.findUnique({
            where: { id },
            include: {
                ratings: true,
            },
        });
        if (!novel) {
            throw new common_1.NotFoundException('Không tìm thấy truyện');
        }
        if (novel.ratings.length === 0) {
            return { average: 0 };
        }
        const sum = novel.ratings.reduce((acc, rating) => acc + rating.score, 0);
        const average = sum / novel.ratings.length;
        return { average };
    }
    async rateNovel(id, userId, ratingData) {
        const novel = await this.databaseService.novel.findUnique({
            where: { id },
        });
        if (!novel) {
            throw new common_1.NotFoundException('Không tìm thấy truyện');
        }
        const existingRating = await this.databaseService.rating.findFirst({
            where: {
                novelId: id,
                userId: userId,
            },
        });
        if (existingRating) {
            throw new common_1.BadRequestException('Bạn đã đánh giá truyện này rồi');
        }
        if (ratingData.score < 1 || ratingData.score > 5) {
            throw new common_1.BadRequestException('Điểm đánh giá phải từ 1 đến 5');
        }
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
    async updateRating(novelId, ratingId, userId, ratingData) {
        const rating = await this.databaseService.rating.findUnique({
            where: { id: ratingId },
        });
        if (!rating) {
            throw new common_1.NotFoundException('Không tìm thấy đánh giá');
        }
        if (rating.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền sửa đánh giá này');
        }
        if (ratingData.score < 1 || ratingData.score > 5) {
            throw new common_1.BadRequestException('Điểm đánh giá phải từ 1 đến 5');
        }
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
};
exports.NovelService = NovelService;
exports.NovelService = NovelService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], NovelService);
//# sourceMappingURL=novel.service.js.map