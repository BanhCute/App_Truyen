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
exports.CreateNovelDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
const novel_status_enum_1 = require("../novel-status.enum");
const class_transformer_1 = require("class-transformer");
class CreateNovelDto {
}
exports.CreateNovelDto = CreateNovelDto;
__decorate([
    (0, class_transformer_1.Expose)(),
    (0, swagger_1.ApiProperty)({ example: 'Tên truyện', description: 'Tên truyện' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateNovelDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'Mô tả truyện',
        description: 'Mô tả truyện',
        required: false,
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], CreateNovelDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'url_cover.jpg',
        description: 'Đường dẫn ảnh bìa',
        required: false,
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], CreateNovelDto.prototype, "cover", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Tên tác giả', description: 'Tên tác giả' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", String)
], CreateNovelDto.prototype, "author", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: novel_status_enum_1.NovelStatus.ONGOING,
        description: 'Trạng thái truyện',
        enum: novel_status_enum_1.NovelStatus,
        enumName: 'NovelStatus',
    }),
    (0, class_validator_1.IsEnum)(novel_status_enum_1.NovelStatus, {
        message: 'Trạng thái truyện phải là: Đang tiến hành, Hoàn thành hoặc Tạm ngưng',
    }),
    (0, class_transformer_1.Expose)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateNovelDto.prototype, "status", void 0);
//# sourceMappingURL=create-novel.dto.js.map