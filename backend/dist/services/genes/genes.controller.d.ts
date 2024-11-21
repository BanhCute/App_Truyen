import { GenesService } from './genes.service';
import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';
export declare class GenesController {
    private readonly genesService;
    constructor(genesService: GenesService);
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
    findOne(id: string): import("@prisma/client").Prisma.Prisma__GenesClient<{
        name: string;
        description: string | null;
        id: number;
    }, null, import("@prisma/client/runtime/library").DefaultArgs>;
    update(id: string, updateGeneDto: UpdateGeneDto): import("@prisma/client").Prisma.Prisma__GenesClient<{
        name: string;
        description: string | null;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    remove(id: string): import("@prisma/client").Prisma.Prisma__GenesClient<{
        name: string;
        description: string | null;
        id: number;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    test(): Promise<{
        name: string;
        description: string | null;
        id: number;
    }[]>;
}
