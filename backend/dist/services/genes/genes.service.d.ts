import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class GenesService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createGeneDto: CreateGeneDto): import("@prisma/client").Prisma.Prisma__GenesClient<{
        id: number;
        name: string;
        description: string | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    findAll(): import("@prisma/client").Prisma.PrismaPromise<{
        id: number;
        name: string;
        description: string | null;
    }[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__GenesClient<{
        id: number;
        name: string;
        description: string | null;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateGeneDto: UpdateGeneDto): import("@prisma/client").Prisma.Prisma__GenesClient<{
        id: number;
        name: string;
        description: string | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    remove(id: number): import("@prisma/client").Prisma.Prisma__GenesClient<{
        id: number;
        name: string;
        description: string | null;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
}
