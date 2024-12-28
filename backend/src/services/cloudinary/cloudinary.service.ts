import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary, UploadApiResponse } from 'cloudinary';
import { Readable } from 'stream';
import { AppConfig } from 'src/config/configuration';

@Injectable()
export class CloudinaryService {
  constructor(private configService: ConfigService<AppConfig>) {
    const cloudName = this.configService.get('cloudinary')?.cloudName;
    const apiKey = this.configService.get('cloudinary')?.apiKey;
    const apiSecret = this.configService.get('cloudinary')?.apiSecret;

    console.log('Cloudinary Config:', {
      cloudName,
      apiKey: apiKey ? 'exists' : 'missing',
      apiSecret: apiSecret ? 'exists' : 'missing',
    });

    cloudinary.config({
      cloud_name: cloudName,
      api_key: apiKey,
      api_secret: apiSecret,
    });
  }

  async uploadImage(
    folder: string,
    buffer: Buffer,
  ): Promise<UploadApiResponse> {
    try {
      console.log('Starting upload to cloudinary...', { folder });
      return new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            folder,
            resource_type: 'auto',
          },
          (error, result) => {
            if (error) {
              console.error('Cloudinary upload error:', error);
              reject(error);
            } else {
              console.log('Cloudinary upload success:', result.secure_url);
              resolve(result);
            }
          },
        );

        const readableStream = new Readable();
        readableStream.push(buffer);
        readableStream.push(null);
        readableStream.pipe(uploadStream);
      });
    } catch (error) {
      console.error('Error in uploadImage:', error);
      throw error;
    }
  }
}
