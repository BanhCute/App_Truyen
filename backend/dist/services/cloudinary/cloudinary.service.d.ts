import { ConfigService } from '@nestjs/config';
import { UploadApiResponse } from 'cloudinary';
import { AppConfig } from 'src/config/configuration';
export declare class CloudinaryService {
    private configService;
    constructor(configService: ConfigService<AppConfig>);
    uploadImage(folder: string, buffer: Buffer): Promise<UploadApiResponse>;
}
