import { Module } from '@nestjs/common';
import { NovelService } from './novel.service';
import { NovelController } from './novel.controller';
import { DatabaseService } from 'src/services/database/database.service';

@Module({
  controllers: [NovelController],
  providers: [NovelService, DatabaseService],
})
export class NovelModule {}
