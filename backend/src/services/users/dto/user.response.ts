import { Expose } from 'class-transformer';

export class UserResponse {
  @Expose()
  id: number;

  @Expose()
  avatar: string | null;

  @Expose()
  name: string;
}

export class UserProfileResponse {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  about: string;

  @Expose()
  avatar: string | null;
}
