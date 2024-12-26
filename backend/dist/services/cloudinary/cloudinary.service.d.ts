import { ConfigService } from '@nestjs/config';
import { UploadApiResponse } from 'cloudinary';
import { AppConfig } from 'src/config/configuration';
export declare class CloudinaryService {
    private readonly configService;
    constructor(configService: ConfigService<AppConfig>);
    uploadImage(folder: string, imageBuffer: Buffer, publicId?: string): Promise<UploadApiResponse>;
    deleteImage(url: string): Promise<unknown>;
    randomPublicId(): string;
}
