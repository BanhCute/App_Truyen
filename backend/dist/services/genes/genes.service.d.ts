import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class GenesService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createGeneDto: CreateGeneDto): Promise<{
        description: string | null;
        name: string;
        id: number;
    }>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<{
        description: string | null;
        name: string;
        id: number;
    }[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__GenesClient<{
        description: string | null;
        name: string;
        id: number;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateGeneDto: UpdateGeneDto): import("@prisma/client").Prisma.Prisma__GenesClient<{
        description: string | null;
        name: string;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    remove(id: number): import("@prisma/client").Prisma.Prisma__GenesClient<{
        description: string | null;
        name: string;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
}
