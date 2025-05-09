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
const class_transformer_1 = require("class-transformer");
const chapter_dto_1 = require("../../chapters/dto/chapter.dto");
const novel_dto_1 = require("../../novel/dto/novel.dto");
const user_response_1 = require("../../users/dto/user.response");
class CommentDto {
}
exports.default = CommentDto;
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], CommentDto.prototype, "id", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], CommentDto.prototype, "chapterId", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], CommentDto.prototype, "userId", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], CommentDto.prototype, "content", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Date)
], CommentDto.prototype, "createdAt", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", chapter_dto_1.default)
], CommentDto.prototype, "chapter", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", user_response_1.UserResponse)
], CommentDto.prototype, "user", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Number)
], CommentDto.prototype, "novelId", void 0);
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", novel_dto_1.default)
], CommentDto.prototype, "Novel", void 0);
//# sourceMappingURL=comments.dto.js.map