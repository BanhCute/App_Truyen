import { GithubOauthGuard } from './github.guard';

describe('GithubGuard', () => {
  it('should be defined', () => {
    expect(new GithubOauthGuard()).toBeDefined();
  });
});
