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
exports.FollowsService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../database/database.service");
let FollowsService = class FollowsService {
    constructor(databaseService) {
        this.databaseService = databaseService;
    }
    async create(createFollowDto, userId) {
        const novel = await this.databaseService.novel.findUnique({
            where: { id: createFollowDto.novelId },
        });
        if (!novel) {
            throw new common_1.NotFoundException(`Novel với ID ${createFollowDto.novelId} không tồn tại`);
        }
        const existingFollow = await this.databaseService.follow.findFirst({
            where: {
                AND: [{ novelId: createFollowDto.novelId }, { userId: userId }],
            },
        });
        if (existingFollow) {
            throw new common_1.BadRequestException('Bạn đã follow truyện này rồi');
        }
        return this.databaseService.follow.create({
            data: {
                novelId: createFollowDto.novelId,
                userId: userId,
                createdAt: new Date(),
            },
        });
    }
    findAll(userId) {
        return this.databaseService.follow.findMany({
            where: {
                userId: userId,
            },
            distinct: ['novelId'],
            orderBy: {
                createdAt: 'desc',
            },
        });
    }
    async findOne(id) {
        const follow = await this.databaseService.follow.findUnique({
            where: { id },
            include: {
                novel: true,
                user: true,
            },
        });
        if (!follow) {
            throw new common_1.NotFoundException(`Follow với ID ${id} không tồn tại`);
        }
        return follow;
    }
    async remove(id, userId) {
        const follow = await this.databaseService.follow.findUnique({
            where: { id },
        });
        if (!follow) {
            throw new common_1.NotFoundException(`Follow với ID ${id} không tồn tại`);
        }
        if (follow.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền xóa follow này');
        }
        return this.databaseService.follow.delete({
            where: { id },
            include: {
                novel: true,
                user: true,
            },
        });
    }
    async removeByNovelId(novelId, userId) {
        const follow = await this.databaseService.follow.findFirst({
            where: {
                novelId,
                userId,
            },
        });
        if (!follow) {
            throw new common_1.NotFoundException('Follow not found');
        }
        return this.databaseService.follow.delete({
            where: {
                id: follow.id,
            },
        });
    }
};
exports.FollowsService = FollowsService;
exports.FollowsService = FollowsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], FollowsService);
//# sourceMappingURL=follows.service.js.map