import { Test, TestingModule } from '@nestjs/testing';
import { GenesController } from './genes.controller';
import { GenesService } from './genes.service';

describe('GenesController', () => {
  let controller: GenesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [GenesController],
      providers: [GenesService],
    }).compile();

    controller = module.get<GenesController>(GenesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
