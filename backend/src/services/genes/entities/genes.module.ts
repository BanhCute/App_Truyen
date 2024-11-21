import { Module } from '@nestjs/common';
import { GenesService } from './genes.service';
import { GenesController } from './genes.controller';

@Module({
  controllers: [GenesController],
  providers: [GenesService],
})
export class GenesModule {}
