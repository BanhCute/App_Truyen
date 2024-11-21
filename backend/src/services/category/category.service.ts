import { Injectable } from '@nestjs/common';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { DatabaseService } from 'src/services/database/database.service';

@Injectable()
export class CategoryService {
  constructor(private readonly databaseService: DatabaseService) {}

  create(createCategoryDto: CreateCategoryDto) {
    console.log(createCategoryDto);
    return this.databaseService.category.create({
      data: createCategoryDto,
    });
  }

  findAll() {
    return this.databaseService.category.findMany();
  }

  findOne(id: number) {
    return this.databaseService.category.findUnique({
      where: { id },
    });
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
