import { Expose, Transform } from 'class-transformer';

export default class UserDto {
  @Expose()
  id: number;

  @Expose()
  name: string;

  @Expose()
  @Transform(({ value }) => value || '')
  avatar: string;

  @Expose()
  @Transform(({ value }) => !value)
  isDeleted: boolean;

  @Expose()
  @Transform(({ value }) => !value)
  isBanned: boolean;
}
