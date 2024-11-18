import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
} from '@nestjs/common';
import { CategoryService } from './category.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import CategoryDto from 'src/services/category/dto/category.dto';
import { plainToInstance } from 'class-transformer';

@Controller('categories')
export class CategoryController {
  constructor(private readonly categoryService: CategoryService) {}

  @Post()
  create(@Body() createCategoryDto: CreateCategoryDto) {
    return plainToInstance(
      CategoryDto,
      this.categoryService.create(createCategoryDto),
    );
  }

  @Get()
  findAll() {
    return this.categoryService
      .findAll()
      .then((items) => items.map((item) => plainToInstance(CategoryDto, item)));
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(CategoryDto, this.categoryService.findOne(id));
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateCategoryDto: UpdateCategoryDto,
  ) {
    return plainToInstance(
      CategoryDto,
      this.categoryService.update(id, updateCategoryDto),
    );
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return plainToInstance(CategoryDto, this.categoryService.remove(id));
  }
}
