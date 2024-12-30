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
exports.RatingsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../database/database.service");
let RatingsService = class RatingsService {
    constructor(databaseService) {
        this.databaseService = databaseService;
    }
    async create(createRatingDto, userId) {
        const novel = await this.databaseService.novel.findUnique({
            where: { id: createRatingDto.novelId },
        });
        if (!novel) {
            throw new common_1.NotFoundException(`Novel với ID ${createRatingDto.novelId} không tồn tại`);
        }
        const existingRating = await this.databaseService.rating.findFirst({
            where: {
                novelId: createRatingDto.novelId,
                userId: userId,
            },
        });
        if (existingRating) {
            throw new common_1.BadRequestException('Bạn đã đánh giá truyện này rồi và không thể đánh giá lại');
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
        try {
            console.log('Finding all ratings');
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
                orderBy: {
                    createdAt: 'desc',
                },
            });
        }
        catch (error) {
            console.error('Error finding all ratings:', error);
            return [];
        }
    }
    async findAllByNovelWithUser(novelId, page = 1, limit = 10) {
        console.log(`Finding ratings for novel ${novelId} in database (page ${page}, limit ${limit})`);
        try {
            const skip = (page - 1) * limit;
            console.log('Testing database connection...');
            const testQuery = await this.databaseService.$queryRaw `SELECT 1`;
            console.log('Database connection test result:', testQuery);
            console.log('Getting ratings with user info...');
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
            }));
            const result = {
                items: transformedRatings,
                meta: {
                    page,
                    limit,
                    total,
                    totalPages: Math.ceil(total / limit),
                },
            };
            console.log('Transformed result:', JSON.stringify(result, null, 2));
            return result;
        }
        catch (error) {
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
    async findOne(id) {
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
            throw new common_1.NotFoundException(`Rating với ID ${id} không tồn tại`);
        }
        return rating;
    }
    async update(id, updateRatingDto, userId) {
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
            throw new common_1.NotFoundException(`Rating với ID ${id} không tồn tại`);
        }
        if (rating.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền sửa đánh giá này');
        }
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
};
exports.RatingsService = RatingsService;
exports.RatingsService = RatingsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], RatingsService);
//# sourceMappingURL=ratings.service.js.map