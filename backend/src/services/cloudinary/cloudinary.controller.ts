import {
  Controller,
  Post,
  Body,
  UseGuards,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { CloudinaryService } from './cloudinary.service';
import { FormDataRequest } from 'nestjs-form-data';
import { CreateCloudinaryDto } from './dto/create.cloudinary.dto';
import { Expose, plainToInstance } from 'class-transformer';
import { AuthGuard } from '../auth/auth.guard';
import { UploadApiResponse } from 'cloudinary';

@Controller('cloudinary')
@UseGuards(AuthGuard)
export class CloudinaryController {
  constructor(private readonly cloudinaryService: CloudinaryService) {}

  @Post()
  @FormDataRequest()
  async create(@Body() createCloudinaryDto: CreateCloudinaryDto) {
    try {
      console.log('Received upload request:', {
        imageCount: createCloudinaryDto.image?.length,
        firstImageSize: createCloudinaryDto.image?.[0]?.size,
      });

      if (
        !createCloudinaryDto.image ||
        createCloudinaryDto.image.length === 0
      ) {
        throw new HttpException('No images provided', HttpStatus.BAD_REQUEST);
      }

      const uploadPromises = createCloudinaryDto.image.map((file) =>
        this.cloudinaryService.uploadImage('images', file.buffer),
      );

      const results = await Promise.all(uploadPromises);
      console.log('Upload completed:', results.length);

      return plainToInstance(CloudinaryResponse, {
        urls: results.map((r: UploadApiResponse) => r.secure_url),
      });
    } catch (error) {
      console.error('Error in cloudinary controller:', error);
      throw new HttpException(
        error.message || 'Upload failed',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}

class CloudinaryResponse {
  @Expose()
  public urls: string[];
}
