import { ConfigService } from '@nestjs/config';
import { AppConfig } from 'src/config/configuration';
export declare class CloudinaryService {
    private readonly configService;
    constructor(configService: ConfigService<AppConfig>);
    uploadImage(folder: string, imageBuffer: Buffer, publicId?: string): Promise<{
        url: string;
    }>;
    deleteImage(url: string): Promise<unknown>;
    randomPublicId(): string;
}
