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
    async findOne(id) {
        const rating = await this.databaseService.rating.findUnique({
            where: { id },
            include: {
                novel: true,
                user: true,
            },
        });
        if (!rating) {
            throw new common_1.NotFoundException(`Rating với ID ${id} không tồn tại`);
        }
        return rating;
    }
};
exports.RatingsService = RatingsService;
exports.RatingsService = RatingsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], RatingsService);
//# sourceMappingURL=ratings.service.js.map