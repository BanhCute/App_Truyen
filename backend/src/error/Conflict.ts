import { ConflictException } from '@nestjs/common';

export default class Conflict<T extends Record<string, any>> extends ConflictException {
  constructor(...fields: (keyof T)[]) {
    super({
      fields,
    });
  }
}
