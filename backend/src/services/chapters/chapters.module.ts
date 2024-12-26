import { Module } from '@nestjs/common';
import { ChaptersService } from './chapters.service';
import { ChaptersController } from './chapters.controller';
import { DatabaseService } from 'src/services/database/database.service';

@Module({
  controllers: [ChaptersController],
  providers: [ChaptersService, DatabaseService],
})
export class ChaptersModule {}
