import {
  IsFile,
  MaxFileSize,
  MemoryStoredFile,
  HasMimeType,
} from 'nestjs-form-data';

export class CreateCloudinaryDto {
  @IsFile()
  @MaxFileSize(5e6)
  @HasMimeType(['image/jpeg', 'image/png', 'image/webp'])
  images: MemoryStoredFile[];
}
