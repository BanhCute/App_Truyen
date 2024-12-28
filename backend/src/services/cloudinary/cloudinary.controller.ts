import { Controller, Post, Body, UseGuards } from '@nestjs/common';
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
      console.log('Uploading images:', createCloudinaryDto.image.length);
      const uploadPromises = createCloudinaryDto.image.map((file) =>
        this.cloudinaryService.uploadImage('images', file.buffer),
      );

      const results = await Promise.all(uploadPromises);
      console.log('Upload results:', results);

      return plainToInstance(CloudinaryResponse, {
        urls: results.map((r: UploadApiResponse) => r.secure_url),
      });
    } catch (error) {
      console.error('Error uploading to cloudinary:', error);
      throw error;
    }
  }
}

class CloudinaryResponse {
  @Expose()
  public urls: string[];
}
