import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class CategoryService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createCategoryDto: CreateCategoryDto): import("@prisma/client").Prisma.Prisma__CategoryClient<{
        id: number;
        name: string;
        description: string | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    findAll(): Promise<{
        id: number;
        name: string;
        description: string | null;
    }[]>;
    findOne(id: number): Promise<{
        id: number;
        name: string;
        description: string | null;
    }>;
    update(id: number, updateCategoryDto: UpdateCategoryDto): import("@prisma/client").Prisma.Prisma__CategoryClient<{
        id: number;
        name: string;
        description: string | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    remove(id: number): import("@prisma/client").Prisma.Prisma__CategoryClient<{
        id: number;
        name: string;
        description: string | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
}
