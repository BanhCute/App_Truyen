import { CloudinaryService } from './cloudinary.service';
import { CreateCloudinaryDto } from './dto/create.cloudinary.dto';
export declare class CloudinaryController {
    private readonly cloudinaryService;
    constructor(cloudinaryService: CloudinaryService);
    create(createCloudinaryDto: CreateCloudinaryDto): Promise<CloudinaryResponse>;
}
declare class CloudinaryResponse {
    urls: string[];
}
export {};
