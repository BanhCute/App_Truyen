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
exports.NovelCategoryDto = exports.CategoryDto = void 0;
const class_transformer_1 = require("class-transformer");
class CategoryDto {
}
exports.CategoryDto = CategoryDto;
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], CategoryDto.prototype, "id", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], CategoryDto.prototype, "name", void 0);
class NovelCategoryDto {
}
exports.NovelCategoryDto = NovelCategoryDto;
__decorate([
    (0, class_transformer_1.Expose)(),
    (0, class_transformer_1.Type)(() => CategoryDto),
    __metadata("design:type", CategoryDto)
], NovelCategoryDto.prototype, "category", void 0);
class NovelDto {
}
exports.default = NovelDto;
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], NovelDto.prototype, "id", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], NovelDto.prototype, "name", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], NovelDto.prototype, "description", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Date)
], NovelDto.prototype, "createdAt", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], NovelDto.prototype, "cover", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], NovelDto.prototype, "author", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], NovelDto.prototype, "status", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], NovelDto.prototype, "view", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Date)
], NovelDto.prototype, "updatedAt", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], NovelDto.prototype, "rating", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], NovelDto.prototype, "followerCount", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], NovelDto.prototype, "commentCount", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], NovelDto.prototype, "userId", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    (0, class_transformer_1.Type)(() => NovelCategoryDto),
    __metadata("design:type", Array)
], NovelDto.prototype, "categories", void 0);
//# sourceMappingURL=novel.dto.js.map