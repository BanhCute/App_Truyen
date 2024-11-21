import { GenesService } from './genes.service';
import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';
import GeneDto from './dto/gene.dto';
export declare class GenesController {
    private readonly genesService;
    constructor(genesService: GenesService);
    create(createGeneDto: CreateGeneDto): Promise<GeneDto>;
    findAll(): Promise<GeneDto[]>;
    findOne(id: number): GeneDto;
    update(id: number, updateGeneDto: UpdateGeneDto): GeneDto;
    remove(id: number): GeneDto;
}
