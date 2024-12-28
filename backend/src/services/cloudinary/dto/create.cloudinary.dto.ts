import {
  IsFile,
  MaxFileSize,
  MemoryStoredFile,
  HasMimeType,
} from 'nestjs-form-data';

export class CreateCloudinaryDto {
  @IsFile({ each: true })
  @MaxFileSize(5e6, { each: true })
  @HasMimeType(['image/jpeg', 'image/png', 'image/webp'], { each: true })
  image: MemoryStoredFile[];
}
