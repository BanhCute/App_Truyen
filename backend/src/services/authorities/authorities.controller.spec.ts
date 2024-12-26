import { Test, TestingModule } from '@nestjs/testing';
import { AuthoritiesController } from './authorities.controller';
import { AuthoritiesService } from './authorities.service';

describe('AuthoritiesController', () => {
  let controller: AuthoritiesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthoritiesController],
      providers: [AuthoritiesService],
    }).compile();

    controller = module.get<AuthoritiesController>(AuthoritiesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
