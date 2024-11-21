import { Injectable } from '@nestjs/common';
import { CreateGeneDto } from '../dto/create-gene.dto';
import { UpdateGeneDto } from '../dto/update-gene.dto';

@Injectable()
export class GenesService {
  create(createGeneDto: CreateGeneDto) {
    return 'This action adds a new gene';
  }

  findAll() {
    return `This action returns all genes`;
  }

  findOne(id: number) {
    return `This action returns a #${id} gene`;
  }

  update(id: number, updateGeneDto: UpdateGeneDto) {
    return `This action updates a #${id} gene`;
  }

  remove(id: number) {
    return `This action removes a #${id} gene`;
  }
}
