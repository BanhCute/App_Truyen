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
exports.CreateGeneDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class CreateGeneDto {
}
exports.CreateGeneDto = CreateGeneDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Isekai', description: 'Tên thể loại' }),
    (0, class_validator_1.IsString)({ message: 'Tên phải là chuỗi' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'Tên không được để trống' }),
    (0, class_validator_1.MinLength)(2, { message: 'Tên phải có ít nhất 2 ký tự' }),
    (0, class_validator_1.MaxLength)(50, { message: 'Tên không được vượt quá 50 ký tự' }),
    __metadata("design:type", String)
], CreateGeneDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'Thể loại dị giới',
        description: 'Mô tả thể loại',
        required: false,
    }),
    (0, class_validator_1.IsString)({ message: 'Mô tả phải là chuỗi' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.MaxLength)(200, { message: 'Mô tả không được vượt quá 200 ký tự' }),
    __metadata("design:type", String)
], CreateGeneDto.prototype, "description", void 0);
//# sourceMappingURL=create-gene.dto.js.map