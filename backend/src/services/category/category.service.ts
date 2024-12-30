import { Injectable } from '@nestjs/common';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { DatabaseService } from 'src/services/database/database.service';

@Injectable()
export class CategoryService {
  constructor(private readonly databaseService: DatabaseService) {}

  create(createCategoryDto: CreateCategoryDto) {
    return this.databaseService.category.create({
      data: createCategoryDto,
    });
  }

  async findAll() {
    try {
      console.log('Finding all categories');
      const categories = await this.databaseService.category.findMany({
        where: {
          isDeleted: false,
        },
        orderBy: {
          name: 'asc',
        },
      });

      console.log(`Found ${categories.length} categories:`, categories);
      return categories;
    } catch (error) {
      console.error('Error finding categories:', error);
      throw error;
    }
  }

  async findOne(id: number) {
    try {
      console.log(`Finding category with id ${id}`);
      const category = await this.databaseService.category.findUnique({
        where: {
          id,
          isDeleted: false,
        },
      });

      console.log('Found category:', category);
      return category;
    } catch (error) {
      console.error('Error finding category:', error);
      throw error;
    }
  }

  update(id: number, updateCategoryDto: UpdateCategoryDto) {
    return this.databaseService.category.update({
      where: { id },
      data: updateCategoryDto,
    });
  }

  remove(id: number) {
    return this.databaseService.category.delete({
      where: { id },
    });
  }
}
