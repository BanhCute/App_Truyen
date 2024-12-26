import { Module } from '@nestjs/common';
import { CategoryService } from './category.service';
import { CategoryController } from './category.controller';
import { DatabaseModule } from 'src/services/database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [CategoryController],
  providers: [CategoryService],
})
export class CategoryModule {}
