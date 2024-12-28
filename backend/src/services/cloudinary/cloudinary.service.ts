import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
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

    if (!cloudName || !apiKey || !apiSecret) {
      throw new Error('Missing Cloudinary configuration');
    }

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
    const maxRetries = 3;
    let lastError = null;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        console.log(
          `Upload attempt ${attempt}/${maxRetries} to cloudinary...`,
          { folder },
        );

        const result = await new Promise<UploadApiResponse>(
          (resolve, reject) => {
            const uploadStream = cloudinary.uploader.upload_stream(
              {
                folder,
                resource_type: 'auto',
                timeout: 60000, // 60 seconds timeout
              },
              (error, result) => {
                if (error) {
                  console.error(
                    `Attempt ${attempt}: Cloudinary upload error:`,
                    error,
                  );
                  reject(error);
                } else {
                  console.log(
                    `Attempt ${attempt}: Cloudinary upload success:`,
                    result.secure_url,
                  );
                  resolve(result);
                }
              },
            );

            const readableStream = new Readable();
            readableStream.push(buffer);
            readableStream.push(null);
            readableStream.pipe(uploadStream);
          },
        );

        return result;
      } catch (error) {
        console.error(`Attempt ${attempt}: Error in uploadImage:`, error);
        lastError = error;

        if (attempt === maxRetries) {
          throw new HttpException(
            'Failed to upload image after multiple attempts',
            HttpStatus.BAD_GATEWAY,
          );
        }

        // Wait before retry
        await new Promise((resolve) => setTimeout(resolve, 1000 * attempt));
      }
    }

    throw lastError;
  }
}
