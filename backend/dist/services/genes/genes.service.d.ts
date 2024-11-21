import { DatabaseService } from '../database/database.service';
import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';
export declare class GenesService {
    private readonly databaseService;
    constructor(databaseService: DatabaseService);
    create(createGeneDto: CreateGeneDto): import("@prisma/client").Prisma.Prisma__GenesClient<{
        name: string;
        description: string | null;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    findAll(): Promise<{
        name: string;
        description: string | null;
        id: number;
    }[]>;
    findOne(id: number): import("@prisma/client").Prisma.Prisma__GenesClient<{
        name: string;
        description: string | null;
        id: number;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: number, updateGeneDto: UpdateGeneDto): import("@prisma/client").Prisma.Prisma__GenesClient<{
        name: string;
        description: string | null;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    remove(id: number): import("@prisma/client").Prisma.Prisma__GenesClient<{
        name: string;
        description: string | null;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
}
