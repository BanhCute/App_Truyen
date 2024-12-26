import { BadRequestException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { UploadApiResponse, v2 as cloudinary } from 'cloudinary';
import { AppConfig } from 'src/config/configuration';
import { extractPublicId } from 'cloudinary-build-url';
import * as crypto from 'crypto';

@Injectable()
export class CloudinaryService {
  constructor(private readonly configService: ConfigService<AppConfig>) {
    cloudinary.config({
      api_secret: configService.get<string>('cloudinary.secret'),
      api_key: configService.get<string>('cloudinary.key'),
      cloud_name: configService.get<string>('cloudinary.cloudName'),
    });
  }
  async uploadImage(folder: string, imageBuffer: Buffer, publicId?: string) {
    if (!imageBuffer) {
      throw new BadRequestException('Image is invalid');
    }

    return await new Promise<UploadApiResponse>((resolve, reject) => {
      cloudinary.uploader
        .upload_stream({ folder, format: 'jpg', public_id: publicId }, (error, result) => {
          if (result) {
            return resolve(result);
          }
          return reject(new BadRequestException(error?.message));
        })
        .end(imageBuffer);
    });
  }

  async deleteImage(url: string) {
    return await new Promise((resolve, reject) => {
      const publicId = extractPublicId(url);
      cloudinary.api.delete_resources([publicId], (error, result) => {
        if (result) {
          return resolve(result);
        }
        return reject(error);
      });
    });
  }

  randomPublicId() {
    const buf = new Uint8Array(1);
    return crypto.getRandomValues(buf).toString();
  }
}
