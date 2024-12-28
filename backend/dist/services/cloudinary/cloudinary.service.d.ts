import { ConfigService } from '@nestjs/config';
import { UploadApiResponse } from 'cloudinary';
export declare class CloudinaryService {
    private configService;
    constructor(configService: ConfigService);
    uploadImage(folder: string, buffer: Buffer): Promise<UploadApiResponse>;
}
