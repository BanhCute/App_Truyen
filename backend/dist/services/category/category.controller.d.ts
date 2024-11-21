import { CategoryService } from './category.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import CategoryDto from 'src/services/category/dto/category.dto';
export declare class CategoryController {
    private readonly categoryService;
    constructor(categoryService: CategoryService);
    create(createCategoryDto: CreateCategoryDto): CategoryDto;
    findAll(): Promise<CategoryDto[]>;
    findOne(id: number): CategoryDto;
    update(id: number, updateCategoryDto: UpdateCategoryDto): CategoryDto;
    remove(id: number): CategoryDto;
}
