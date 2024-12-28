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
const stream_1 = require("stream");
let CloudinaryService = class CloudinaryService {
    constructor(configService) {
        this.configService = configService;
        const cloudName = this.configService.get('cloudinary')?.cloudName;
        const apiKey = this.configService.get('cloudinary')?.apiKey;
        const apiSecret = this.configService.get('cloudinary')?.apiSecret;
        if (!cloudName || !apiKey || !apiSecret) {
            throw new Error('Missing Cloudinary configuration');
        }
        console.log('Cloudinary Config:', {
            cloudName,
            apiKey: apiKey ? 'exists' : 'missing',
            apiSecret: apiSecret ? 'exists' : 'missing',
        });
        cloudinary_1.v2.config({
            cloud_name: cloudName,
            api_key: apiKey,
            api_secret: apiSecret,
        });
    }
    async uploadImage(folder, buffer) {
        const maxRetries = 3;
        let lastError = null;
        for (let attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                console.log(`Upload attempt ${attempt}/${maxRetries} to cloudinary...`, { folder });
                const result = await new Promise((resolve, reject) => {
                    const uploadStream = cloudinary_1.v2.uploader.upload_stream({
                        folder,
                        resource_type: 'auto',
                        timeout: 60000,
                    }, (error, result) => {
                        if (error) {
                            console.error(`Attempt ${attempt}: Cloudinary upload error:`, error);
                            reject(error);
                        }
                        else {
                            console.log(`Attempt ${attempt}: Cloudinary upload success:`, result.secure_url);
                            resolve(result);
                        }
                    });
                    const readableStream = new stream_1.Readable();
                    readableStream.push(buffer);
                    readableStream.push(null);
                    readableStream.pipe(uploadStream);
                });
                return result;
            }
            catch (error) {
                console.error(`Attempt ${attempt}: Error in uploadImage:`, error);
                lastError = error;
                if (attempt === maxRetries) {
                    throw new common_1.HttpException('Failed to upload image after multiple attempts', common_1.HttpStatus.BAD_GATEWAY);
                }
                await new Promise((resolve) => setTimeout(resolve, 1000 * attempt));
            }
        }
        throw lastError;
    }
};
exports.CloudinaryService = CloudinaryService;
exports.CloudinaryService = CloudinaryService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], CloudinaryService);
//# sourceMappingURL=cloudinary.service.js.map