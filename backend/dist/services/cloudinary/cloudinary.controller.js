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
exports.CloudinaryController = void 0;
const common_1 = require("@nestjs/common");
const cloudinary_service_1 = require("./cloudinary.service");
const nestjs_form_data_1 = require("nestjs-form-data");
const create_cloudinary_dto_1 = require("./dto/create.cloudinary.dto");
const class_transformer_1 = require("class-transformer");
const auth_guard_1 = require("../auth/auth.guard");
let CloudinaryController = class CloudinaryController {
    constructor(cloudinaryService) {
        this.cloudinaryService = cloudinaryService;
    }
    async create(createCloudinaryDto) {
        try {
            console.log('Received upload request:', {
                imageCount: createCloudinaryDto.image?.length,
                firstImageSize: createCloudinaryDto.image?.[0]?.size,
            });
            if (!createCloudinaryDto.image ||
                createCloudinaryDto.image.length === 0) {
                throw new common_1.HttpException('No images provided', common_1.HttpStatus.BAD_REQUEST);
            }
            const uploadPromises = createCloudinaryDto.image.map((file) => this.cloudinaryService.uploadImage('images', file.buffer));
            const results = await Promise.all(uploadPromises);
            console.log('Upload completed:', results.length);
            return (0, class_transformer_1.plainToInstance)(CloudinaryResponse, {
                urls: results.map((r) => r.secure_url),
            });
        }
        catch (error) {
            console.error('Error in cloudinary controller:', error);
            throw new common_1.HttpException(error.message || 'Upload failed', error.status || common_1.HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
};
exports.CloudinaryController = CloudinaryController;
__decorate([
    (0, common_1.Post)(),
    (0, nestjs_form_data_1.FormDataRequest)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_cloudinary_dto_1.CreateCloudinaryDto]),
    __metadata("design:returntype", Promise)
], CloudinaryController.prototype, "create", null);
exports.CloudinaryController = CloudinaryController = __decorate([
    (0, common_1.Controller)('cloudinary'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    __metadata("design:paramtypes", [cloudinary_service_1.CloudinaryService])
], CloudinaryController);
class CloudinaryResponse {
}
__decorate([
    (0, class_transformer_1.Expose)(),
    __metadata("design:type", Array)
], CloudinaryResponse.prototype, "urls", void 0);
//# sourceMappingURL=cloudinary.controller.js.map