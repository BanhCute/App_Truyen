import { Controller } from '@nestjs/common';
import { AuthoritiesService } from './authorities.service';

@Controller('authorities')
export class AuthoritiesController {
  constructor(private readonly authoritiesService: AuthoritiesService) {}
}
