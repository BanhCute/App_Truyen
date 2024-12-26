import { Test, TestingModule } from '@nestjs/testing';
import { HistorysController } from './historys.controller';
import { HistorysService } from './historys.service';

describe('HistorysController', () => {
  let controller: HistorysController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HistorysController],
      providers: [HistorysService],
    }).compile();

    controller = module.get<HistorysController>(HistorysController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
