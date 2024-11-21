import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class CategoryService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createCategoryDto: CreateCategoryDto): import("@prisma/client").Prisma.Prisma__CategoryClient<{
        description: string | null;
        name: string;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<{
        description: string | null;
        name: string;
        id: number;
    }[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__CategoryClient<{
        description: string | null;
        name: string;
        id: number;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateCategoryDto: UpdateCategoryDto): import("@prisma/client").Prisma.Prisma__CategoryClient<{
        description: string | null;
        name: string;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    remove(id: number): import("@prisma/client").Prisma.Prisma__CategoryClient<{
        description: string | null;
        name: string;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
}
