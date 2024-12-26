import { Test, TestingModule } from '@nestjs/testing';
import { AuthoritiesService } from './authorities.service';

describe('AuthoritiesService', () => {
  let service: AuthoritiesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AuthoritiesService],
    }).compile();

    service = module.get<AuthoritiesService>(AuthoritiesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
