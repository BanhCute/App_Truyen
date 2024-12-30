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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChaptersController = void 0;
const common_1 = require("@nestjs/common");
const chapters_service_1 = require("./chapters.service");
const create_chapter_dto_1 = require("./dto/create-chapter.dto");
const update_chapter_dto_1 = require("./dto/update-chapter.dto");
const chapter_dto_1 = require("./dto/chapter.dto");
const class_transformer_1 = require("class-transformer");
let ChaptersController = class ChaptersController {
    constructor(chaptersService) {
        this.chaptersService = chaptersService;
    }
    async create(createChapterDto) {
        const chapter = await this.chaptersService.create(createChapterDto);
        return (0, class_transformer_1.plainToInstance)(chapter_dto_1.default, chapter);
    }
    async findAll() {
        const chapters = await this.chaptersService.findAll();
        return chapters.map((chapter) => (0, class_transformer_1.plainToInstance)(chapter_dto_1.default, chapter));
    }
    async findOne(id) {
        const chapter = await this.chaptersService.findOne(id);
        return (0, class_transformer_1.plainToInstance)(chapter_dto_1.default, chapter);
    }
    async update(id, updateChapterDto) {
        const chapter = await this.chaptersService.update(id, updateChapterDto);
        return (0, class_transformer_1.plainToInstance)(chapter_dto_1.default, chapter);
    }
    async remove(id) {
        const chapter = await this.chaptersService.remove(id);
        return (0, class_transformer_1.plainToInstance)(chapter_dto_1.default, chapter);
    }
};
exports.ChaptersController = ChaptersController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_chapter_dto_1.CreateChapterDto]),
    __metadata("design:returntype", Promise)
], ChaptersController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ChaptersController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], ChaptersController.prototype, "findOne", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_chapter_dto_1.UpdateChapterDto]),
    __metadata("design:returntype", Promise)
], ChaptersController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], ChaptersController.prototype, "remove", null);
exports.ChaptersController = ChaptersController = __decorate([
    (0, common_1.Controller)('chapters'),
    __metadata("design:paramtypes", [chapters_service_1.ChaptersService])
], ChaptersController);
//# sourceMappingURL=chapters.controller.js.map