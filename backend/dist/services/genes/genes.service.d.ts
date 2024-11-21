import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';
export declare class GenesService {
    create(createGeneDto: CreateGeneDto): string;
    findAll(): string;
    findOne(id: number): string;
    update(id: number, updateGeneDto: UpdateGeneDto): string;
    remove(id: number): string;
}
