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
        console.log('Initializing Cloudinary with:', {
            cloudName,
            apiKey: apiKey ? apiKey.substring(0, 4) + '...' : 'missing',
            apiSecret: apiSecret ? 'exists' : 'missing',
        });
        if (!cloudName || !apiKey || !apiSecret) {
            throw new Error('Missing Cloudinary configuration');
        }
        try {
            cloudinary_1.v2.config({
                cloud_name: cloudName,
                api_key: apiKey,
                api_secret: apiSecret,
            });
            console.log('Cloudinary configured successfully');
        }
        catch (error) {
            console.error('Failed to configure Cloudinary:', error);
            throw error;
        }
    }
    async uploadImage(folder, buffer) {
        const maxRetries = 3;
        let lastError = null;
        for (let attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                console.log(`[Attempt ${attempt}/${maxRetries}] Starting upload to Cloudinary...`, {
                    folder,
                    bufferSize: buffer.length,
                });
                const result = await new Promise((resolve, reject) => {
                    const uploadStream = cloudinary_1.v2.uploader.upload_stream({
                        folder,
                        resource_type: 'auto',
                        timeout: 60000,
                    }, (error, result) => {
                        if (error) {
                            console.error(`[Attempt ${attempt}] Cloudinary upload error:`, {
                                message: error.message,
                                code: error.http_code,
                                name: error.name,
                            });
                            reject(error);
                        }
                        else {
                            console.log(`[Attempt ${attempt}] Cloudinary upload success:`, {
                                publicId: result.public_id,
                                url: result.secure_url,
                                size: result.bytes,
                            });
                            resolve(result);
                        }
                    });
                    const readableStream = new stream_1.Readable({
                        read() {
                            this.push(buffer);
                            this.push(null);
                        },
                    });
                    readableStream.on('error', (error) => {
                        console.error(`[Attempt ${attempt}] Stream error:`, error);
                        reject(error);
                    });
                    uploadStream.on('error', (error) => {
                        console.error(`[Attempt ${attempt}] Upload stream error:`, error);
                        reject(error);
                    });
                    readableStream.pipe(uploadStream);
                });
                return result;
            }
            catch (error) {
                console.error(`[Attempt ${attempt}] Upload failed:`, error);
                lastError = error;
                if (attempt === maxRetries) {
                    throw new common_1.HttpException(`Failed to upload image after ${maxRetries} attempts: ${error.message}`, common_1.HttpStatus.BAD_GATEWAY);
                }
                const delay = Math.min(1000 * Math.pow(2, attempt - 1), 5000);
                console.log(`Waiting ${delay}ms before retry...`);
                await new Promise((resolve) => setTimeout(resolve, delay));
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