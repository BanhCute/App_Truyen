import { Test, TestingModule } from '@nestjs/testing';
import { RoleAuthoritiesController } from './role-authorities.controller';
import { RoleAuthoritiesService } from './role-authorities.service';

describe('RoleAuthoritiesController', () => {
  let controller: RoleAuthoritiesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RoleAuthoritiesController],
      providers: [RoleAuthoritiesService],
    }).compile();

    controller = module.get<RoleAuthoritiesController>(RoleAuthoritiesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
