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
exports.HistorysService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../database/database.service");
let HistorysService = class HistorysService {
    constructor(databaseService) {
        this.databaseService = databaseService;
    }
    async create(createHistoryDto, userId) {
        const novel = await this.databaseService.novel.findUnique({
            where: { id: createHistoryDto.novelId },
        });
        if (!novel) {
            throw new common_1.NotFoundException(`Novel với ID ${createHistoryDto.novelId} không tồn tại`);
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
    async findOne(id) {
        const history = await this.databaseService.history.findUnique({
            where: { id },
            include: {
                novel: true,
            },
        });
        if (!history) {
            throw new common_1.NotFoundException(`History với ID ${id} không tồn tại`);
        }
        return history;
    }
    async remove(id, userId) {
        const history = await this.databaseService.history.findUnique({
            where: { id },
        });
        if (!history) {
            throw new common_1.NotFoundException(`History với ID ${id} không tồn tại`);
        }
        if (history.userId !== userId) {
            throw new common_1.ForbiddenException('Bạn không có quyền xóa history này');
        }
        return this.databaseService.history.delete({
            where: { id },
            include: {
                novel: true,
            },
        });
    }
};
exports.HistorysService = HistorysService;
exports.HistorysService = HistorysService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], HistorysService);
//# sourceMappingURL=historys.service.js.map