import { Controller } from '@nestjs/common';
import { RoleAuthoritiesService } from './role-authorities.service';

@Controller('role-authorities')
export class RoleAuthoritiesController {
  constructor(private readonly roleAuthoritiesService: RoleAuthoritiesService) {}
}
