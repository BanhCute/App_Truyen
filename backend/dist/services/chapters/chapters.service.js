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
exports.ChaptersService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../database/database.service");
let ChaptersService = class ChaptersService {
    constructor(databaseService) {
        this.databaseService = databaseService;
    }
    async create(createChapterDto) {
        const existingChapter = await this.databaseService.chapter.findFirst({
            where: {
                novelId: createChapterDto.novelId,
                name: createChapterDto.name,
            },
        });
        if (existingChapter) {
            throw new common_1.ConflictException('Chapter với tên này đã tồn tại trong novel này');
        }
        return this.databaseService.chapter.create({
            data: createChapterDto,
        });
    }
    async findAll() {
        try {
            const chapters = await this.databaseService.chapter.findMany({
                include: {
                    novel: true,
                    Comment: true,
                },
            });
            if (!chapters || chapters.length === 0) {
                return [];
            }
            return chapters;
        }
        catch (error) {
            console.error('Error in findAll:', error);
            throw error;
        }
    }
    async findOne(id) {
        try {
            const chapter = await this.databaseService.chapter.findUnique({
                where: { id },
                include: {
                    novel: true,
                    Comment: true,
                },
            });
            if (!chapter) {
                throw new common_1.NotFoundException(`Chapter with ID ${id} not found`);
            }
            return chapter;
        }
        catch (error) {
            console.error(`Error in findOne(${id}):`, error);
            throw error;
        }
    }
    async update(id, updateChapterDto) {
        try {
            const currentChapter = await this.databaseService.chapter.findUnique({
                where: { id },
            });
            if (!currentChapter) {
                throw new common_1.NotFoundException(`Chapter với ID ${id} không tồn tại`);
            }
            if ('createdAt' in updateChapterDto) {
                throw new common_1.BadRequestException('Bạn không được phép sửa ngày tạo chapter');
            }
            return await this.databaseService.chapter.update({
                where: { id },
                data: {
                    name: updateChapterDto.name,
                    content: updateChapterDto.content,
                },
            });
        }
        catch (error) {
            if (error instanceof common_1.BadRequestException ||
                error instanceof common_1.NotFoundException) {
                throw error;
            }
            throw new common_1.NotFoundException(`Chapter với ID ${id} không tồn tại`);
        }
    }
    async remove(id) {
        try {
            return await this.databaseService.chapter.delete({
                where: { id },
            });
        }
        catch (error) {
            throw new common_1.NotFoundException(`Chapter with ID ${id} not found`);
        }
    }
};
exports.ChaptersService = ChaptersService;
exports.ChaptersService = ChaptersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], ChaptersService);
//# sourceMappingURL=chapters.service.js.map