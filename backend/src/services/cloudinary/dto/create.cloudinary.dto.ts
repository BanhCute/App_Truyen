import { IsFile, MaxFileSize, MemoryStoredFile } from 'nestjs-form-data';

export class CreateCloudinaryDto {
  @IsFile()
  @MaxFileSize(1e6)
  image: MemoryStoredFile;
}
