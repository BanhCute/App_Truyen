import { GenesService } from './genes.service';
import { CreateGeneDto } from '../dto/create-gene.dto';
import { UpdateGeneDto } from '../dto/update-gene.dto';
export declare class GenesController {
    private readonly genesService;
    constructor(genesService: GenesService);
    create(createGeneDto: CreateGeneDto): string;
    findAll(): string;
    findOne(id: string): string;
    update(id: string, updateGeneDto: UpdateGeneDto): string;
    remove(id: string): string;
}
