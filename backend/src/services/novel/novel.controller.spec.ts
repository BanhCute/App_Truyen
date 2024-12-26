import { Test, TestingModule } from '@nestjs/testing';
import { NovelController } from './novel.controller';
import { NovelService } from './novel.service';

describe('NovelController', () => {
  let controller: NovelController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [NovelController],
      providers: [NovelService],
    }).compile();

    controller = module.get<NovelController>(NovelController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
