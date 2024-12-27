import { CloudinaryService } from 'src/services/cloudinary/cloudinary.service';
import { CreateCloudinaryDto } from 'src/services/cloudinary/dto/create.cloudinary.dto';
export declare class CloudinaryController {
    private readonly cloudinaryService;
    constructor(cloudinaryService: CloudinaryService);
    create(createCloudinaryDto: CreateCloudinaryDto): Promise<CloudinaryResponse>;
}
declare class CloudinaryResponse {
    url: string;
}
export {};
