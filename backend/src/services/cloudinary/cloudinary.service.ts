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

    console.log('Initializing Cloudinary with:', {
      cloudName,
      apiKey: apiKey ? apiKey.substring(0, 4) + '...' : 'missing',
      apiSecret: apiSecret ? 'exists' : 'missing',
    });

    if (!cloudName || !apiKey || !apiSecret) {
      throw new Error('Missing Cloudinary configuration');
    }

    try {
      cloudinary.config({
        cloud_name: cloudName,
        api_key: apiKey,
        api_secret: apiSecret,
      });
      console.log('Cloudinary configured successfully');
    } catch (error) {
      console.error('Failed to configure Cloudinary:', error);
      throw error;
    }
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
          `[Attempt ${attempt}/${maxRetries}] Starting upload to Cloudinary...`,
          {
            folder,
            bufferSize: buffer.length,
          },
        );

        const result = await new Promise<UploadApiResponse>(
          (resolve, reject) => {
            const uploadStream = cloudinary.uploader.upload_stream(
              {
                folder,
                resource_type: 'auto',
                timeout: 60000,
              },
              (error, result) => {
                if (error) {
                  console.error(
                    `[Attempt ${attempt}] Cloudinary upload error:`,
                    {
                      message: error.message,
                      code: error.http_code,
                      name: error.name,
                    },
                  );
                  reject(error);
                } else {
                  console.log(
                    `[Attempt ${attempt}] Cloudinary upload success:`,
                    {
                      publicId: result.public_id,
                      url: result.secure_url,
                      size: result.bytes,
                    },
                  );
                  resolve(result);
                }
              },
            );

            // Pipe the buffer to the upload stream
            const readableStream = new Readable({
              read() {
                this.push(buffer);
                this.push(null);
              },
            });

            readableStream.on('error', (error) => {
              console.error(`[Attempt ${attempt}] Stream error:`, error);
              reject(error);
            });

            uploadStream.on('error', (error) => {
              console.error(`[Attempt ${attempt}] Upload stream error:`, error);
              reject(error);
            });

            readableStream.pipe(uploadStream);
          },
        );

        return result;
      } catch (error) {
        console.error(`[Attempt ${attempt}] Upload failed:`, error);
        lastError = error;

        if (attempt === maxRetries) {
          throw new HttpException(
            `Failed to upload image after ${maxRetries} attempts: ${error.message}`,
            HttpStatus.BAD_GATEWAY,
          );
        }

        // Wait before retry with exponential backoff
        const delay = Math.min(1000 * Math.pow(2, attempt - 1), 5000);
        console.log(`Waiting ${delay}ms before retry...`);
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }

    throw lastError;
  }
}
