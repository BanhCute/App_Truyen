import { Module } from '@nestjs/common';
import { HistorysService } from './historys.service';
import { HistorysController } from './historys.controller';
import { DatabaseModule } from 'src/services/database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [HistorysController],
  providers: [HistorysService],
})
export class HistorysModule {}
