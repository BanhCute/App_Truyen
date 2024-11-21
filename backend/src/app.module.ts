import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CategoryModule } from './services/category/category.module';
import { DatabaseModule } from 'src/services/database/database.module';
import { GenesModule } from './services/genes/entities/genes.module';
import { GenesModule } from './services/genes/entities/genes.module';

@Module({
  imports: [CategoryModule, DatabaseModule, GenesModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
