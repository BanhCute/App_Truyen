import { Test, TestingModule } from '@nestjs/testing';
import { RoleAuthoritiesService } from './role-authorities.service';

describe('RoleAuthoritiesService', () => {
  let service: RoleAuthoritiesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [RoleAuthoritiesService],
    }).compile();

    service = module.get<RoleAuthoritiesService>(RoleAuthoritiesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
