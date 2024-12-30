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
exports.CreateCommentDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class CreateCommentDto {
}
exports.CreateCommentDto = CreateCommentDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 1, description: 'ID của chapter' }),
    (0, class_validator_1.IsNumber)({}, { message: 'Chapter ID phải là số' }),
    __metadata("design:type", Number)
], CreateCommentDto.prototype, "chapterId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Truyện hay quá!', description: 'Nội dung bình luận' }),
    (0, class_validator_1.IsString)({ message: 'Nội dung phải là chuỗi' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Nội dung không được để trống' }),
    __metadata("design:type", String)
], CreateCommentDto.prototype, "content", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 1, description: 'ID của novel (tùy chọn)', required: false }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)({}, { message: 'Novel ID phải là số' }),
    __metadata("design:type", Number)
], CreateCommentDto.prototype, "novelId", void 0);
//# sourceMappingURL=create-comment.dto.js.map