import { Controller, Post, Body } from '@nestjs/common';
import { CloudinaryService } from 'src/services/cloudinary/cloudinary.service';
import { FormDataRequest } from 'nestjs-form-data';
import { CreateCloudinaryDto } from 'src/services/cloudinary/dto/create.cloudinary.dto';
import { Expose, plainToInstance } from 'class-transformer';

@Controller('cloudinary')
export class CloudinaryController {
  constructor(private readonly cloudinaryService: CloudinaryService) {}

  @Post()
  @FormDataRequest()
  async create(@Body() createCloudinaryDto: CreateCloudinaryDto) {
    const uploadPromises = createCloudinaryDto.image.map((file) =>
      this.cloudinaryService.uploadImage('images', file.buffer),
    );

    const results = await Promise.all(uploadPromises);
    return plainToInstance(CloudinaryResponse, {
      urls: results.map((r) => r.url),
    });
  }
}

class CloudinaryResponse {
  @Expose()
  public urls: string[];
}
