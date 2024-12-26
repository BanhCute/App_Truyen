import { Test, TestingModule } from '@nestjs/testing';
import { HistorysService } from './historys.service';

describe('HistorysService', () => {
  let service: HistorysService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [HistorysService],
    }).compile();

    service = module.get<HistorysService>(HistorysService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
