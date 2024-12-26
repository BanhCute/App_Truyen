import { Test, TestingModule } from '@nestjs/testing';
import { GithubOauthController } from './github.controller';

describe('GithubController', () => {
  let controller: GithubOauthController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [GithubOauthController],
    }).compile();

    controller = module.get<GithubOauthController>(GithubOauthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
