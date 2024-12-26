import { Controller, Post, Body } from '@nestjs/common';
import { CloudinaryService } from 'src/services/cloudinary/cloudinary.service';
import { FormDataRequest } from 'nestjs-form-data';
import { CreateCloudinaryDto } from 'src/services/cloudinary/dto/create.cloudinary.dto';

@Controller('cloudinary')
export class CloudinaryController {
  constructor(private readonly cloudinaryService: CloudinaryService) {}

  @Post()
  @FormDataRequest()
  async create(@Body() createCloudinaryDto: CreateCloudinaryDto) {
    return this.cloudinaryService.uploadImage(
      'images',
      createCloudinaryDto.image.buffer,
    );
  }
}
