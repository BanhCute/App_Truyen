import { Test, TestingModule } from '@nestjs/testing';
import { GenesService } from './genes.service';

describe('GenesService', () => {
  let service: GenesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [GenesService],
    }).compile();

    service = module.get<GenesService>(GenesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
