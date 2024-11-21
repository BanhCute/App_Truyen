import { Injectable } from '@nestjs/common';
import { CreateGeneDto } from './dto/create-gene.dto';
import { UpdateGeneDto } from './dto/update-gene.dto';
import { DatabaseService } from 'src/services/database/database.service';

@Injectable()
export class GenesService {
  constructor(private readonly databaseService: DatabaseService) {}

  async create(createGeneDto: CreateGeneDto) {
    try {
      return await this.databaseService.genes.create({
        data: {
          name: createGeneDto.name,
          description: createGeneDto.description
        },
      });
    } catch (error) {
      console.log('Database Error:', error);
      throw error;
    }
  }

  findAll() {
    return this.databaseService.genes.findMany();
  }

  findOne(id: number) {
    return this.databaseService.genes.findUnique({
      where: { id },
    });
  }

  update(id: number, updateGeneDto: UpdateGeneDto) {
    return this.databaseService.genes.update({
      where: { id },
      data: updateGeneDto,
    });
  }

  remove(id: number) {
    return this.databaseService.genes.delete({
      where: { id },
    });
  }
}
