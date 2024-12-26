import { CloudinaryController } from 'src/services/cloudinary/cloudinary.controller';
import { CloudinaryService } from './cloudinary.service';
import { Module } from '@nestjs/common';

@Module({
  providers: [CloudinaryService],
  exports: [CloudinaryService],
  controllers: [CloudinaryController],
})
export class CloudinaryModule {}
