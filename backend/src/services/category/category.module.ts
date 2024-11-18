import { Module } from '@nestjs/common';
import { CategoryService } from './category.service';
import { CategoryController } from './category.controller';
import { DatabaseService } from 'src/services/database/database.service';

@Module({
  controllers: [CategoryController],
  providers: [CategoryService, DatabaseService],
})
export class CategoryModule {}
