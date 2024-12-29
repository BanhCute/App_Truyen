import { Expose } from 'class-transformer';

export default class UserDto {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  avatar: string;
}
