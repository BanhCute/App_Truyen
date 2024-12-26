import { NotFoundException } from '@nestjs/common';

export default class NotFound<T extends Record<string, any>> extends NotFoundException {
  constructor(...fields: (keyof T)[]) {
    super({
      fields,
    });
  }
}
