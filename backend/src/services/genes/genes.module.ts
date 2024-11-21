import { Module } from '@nestjs/common';
import { GenesService } from './genes.service';
import { GenesController } from './genes.controller';
import { DatabaseService } from '../database/database.service';

@Module({
  controllers: [GenesController],
  providers: [GenesService, DatabaseService],
})
export class GenesModule {}
