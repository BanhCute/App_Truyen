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
exports.CreateChapterDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class CreateChapterDto {
}
exports.CreateChapterDto = CreateChapterDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'Chapter 1: Bắt đầu cuộc phiêu lưu',
        description: 'Tên chapter'
    }),
    (0, class_validator_1.IsString)({ message: 'Tên chapter phải là chuỗi' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Tên chapter không được để trống' }),
    (0, class_validator_1.MinLength)(2, { message: 'Tên chapter phải có ít nhất 2 ký tự' }),
    (0, class_validator_1.MaxLength)(100, { message: 'Tên chapter không được vượt quá 100 ký tự' }),
    __metadata("design:type", String)
], CreateChapterDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 1,
        description: 'ID của novel mà chapter thuộc về'
    }),
    (0, class_validator_1.IsNumber)({}, { message: 'ID novel phải là số' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'ID novel không được để trống' }),
    __metadata("design:type", Number)
], CreateChapterDto.prototype, "novelId", void 0);
//# sourceMappingURL=create-chapter.dto.js.map