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
exports.CloudinaryService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const cloudinary_1 = require("cloudinary");
const cloudinary_build_url_1 = require("cloudinary-build-url");
const crypto = require("crypto");
let CloudinaryService = class CloudinaryService {
    constructor(configService) {
        this.configService = configService;
        cloudinary_1.v2.config({
            api_secret: configService.get('cloudinary.secret'),
            api_key: configService.get('cloudinary.key'),
            cloud_name: configService.get('cloudinary.cloudName'),
        });
    }
    async uploadImage(folder, imageBuffer, publicId) {
        if (!imageBuffer) {
            throw new common_1.BadRequestException('Image is invalid');
        }
        const result = await new Promise((resolve, reject) => {
            cloudinary_1.v2.uploader
                .upload_stream({ folder, format: 'jpg', public_id: publicId }, (error, result) => {
                if (result) {
                    return resolve(result);
                }
                return reject(new common_1.BadRequestException(error?.message));
            })
                .end(imageBuffer);
        });
        return { url: result.secure_url };
    }
    async deleteImage(url) {
        return await new Promise((resolve, reject) => {
            const publicId = (0, cloudinary_build_url_1.extractPublicId)(url);
            cloudinary_1.v2.api.delete_resources([publicId], (error, result) => {
                if (result) {
                    return resolve(result);
                }
                return reject(error);
            });
        });
    }
    randomPublicId() {
        const buf = new Uint8Array(1);
        return crypto.getRandomValues(buf).toString();
    }
};
exports.CloudinaryService = CloudinaryService;
exports.CloudinaryService = CloudinaryService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], CloudinaryService);
//# sourceMappingURL=cloudinary.service.js.map