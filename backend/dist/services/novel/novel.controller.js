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
exports.NovelController = void 0;
const common_1 = require("@nestjs/common");
const novel_service_1 = require("./novel.service");
const create_novel_dto_1 = require("./dto/create-novel.dto");
const update_novel_dto_1 = require("./dto/update-novel.dto");
const novel_dto_1 = require("./dto/novel.dto");
const class_transformer_1 = require("class-transformer");
const auth_utils_1 = require("../auth/auth.utils");
let NovelController = class NovelController {
    constructor(novelService) {
        this.novelService = novelService;
    }
    create(createNovelDto, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return (0, class_transformer_1.plainToInstance)(novel_dto_1.default, this.novelService.create((0, class_transformer_1.plainToClass)(create_novel_dto_1.CreateNovelDto, createNovelDto, {
            strategy: 'excludeAll',
        }), session.id));
    }
    async findAll() {
        const data = await this.novelService
            .findAll()
            .then((items) => items.map((item) => (0, class_transformer_1.plainToInstance)(novel_dto_1.default, item)));
        return data;
    }
    async findOne(id) {
        console.log(`GET /novels/${id}`);
        const novel = await this.novelService.findOne(id);
        if (!novel) {
            throw new common_1.NotFoundException('Không tìm thấy truyện');
        }
        const result = (0, class_transformer_1.plainToInstance)(novel_dto_1.default, novel);
        console.log('Response:', JSON.stringify(result, null, 2));
        return result;
    }
    update(id, updateNovelDto, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return (0, class_transformer_1.plainToInstance)(novel_dto_1.default, this.novelService.update(id, updateNovelDto, session.id));
    }
    remove(id, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return (0, class_transformer_1.plainToInstance)(novel_dto_1.default, this.novelService.remove(id, session.id));
    }
    async addCategories(id, categoryIds, req) {
        const session = (0, auth_utils_1.getSession)(req);
        const result = await this.novelService.addCategories(id, categoryIds, session.id);
        return (0, class_transformer_1.plainToInstance)(novel_dto_1.default, result);
    }
    async removeCategory(id, categoryId, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return this.novelService.removeCategory(id, categoryId, session.id);
    }
    async getNovelRatings(id) {
        console.log(`Getting ratings for novel ${id}`);
        const ratings = await this.novelService.getNovelRatings(id);
        console.log('Found ratings:', JSON.stringify(ratings, null, 2));
        return ratings;
    }
    async getAverageRating(id) {
        return this.novelService.getAverageRating(id);
    }
    async rateNovel(id, ratingData, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return this.novelService.rateNovel(id, session.id, ratingData);
    }
    async updateRating(id, ratingId, ratingData, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return this.novelService.updateRating(id, ratingId, session.id, ratingData);
    }
};
exports.NovelController = NovelController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_novel_dto_1.CreateNovelDto, Object]),
    __metadata("design:returntype", void 0)
], NovelController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], NovelController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], NovelController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_novel_dto_1.UpdateNovelDto, Object]),
    __metadata("design:returntype", void 0)
], NovelController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], NovelController.prototype, "remove", null);
__decorate([
    (0, common_1.Post)(':id/categories'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)('categoryIds')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Array, Object]),
    __metadata("design:returntype", Promise)
], NovelController.prototype, "addCategories", null);
__decorate([
    (0, common_1.Delete)(':id/categories/:categoryId'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Param)('categoryId', common_1.ParseIntPipe)),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Object]),
    __metadata("design:returntype", Promise)
], NovelController.prototype, "removeCategory", null);
__decorate([
    (0, common_1.Get)(':id/ratings'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], NovelController.prototype, "getNovelRatings", null);
__decorate([
    (0, common_1.Get)(':id/ratings/average'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], NovelController.prototype, "getAverageRating", null);
__decorate([
    (0, common_1.Post)(':id/ratings'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object, Object]),
    __metadata("design:returntype", Promise)
], NovelController.prototype, "rateNovel", null);
__decorate([
    (0, common_1.Patch)(':id/ratings/:ratingId'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Param)('ratingId', common_1.ParseIntPipe)),
    __param(2, (0, common_1.Body)()),
    __param(3, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Object, Object]),
    __metadata("design:returntype", Promise)
], NovelController.prototype, "updateRating", null);
exports.NovelController = NovelController = __decorate([
    (0, common_1.Controller)('novels'),
    __metadata("design:paramtypes", [novel_service_1.NovelService])
], NovelController);
//# sourceMappingURL=novel.controller.js.map