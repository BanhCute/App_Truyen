import { Module } from '@nestjs/common';
import { RoleAuthoritiesService } from './role-authorities.service';
import { RoleAuthoritiesController } from './role-authorities.controller';

@Module({
  controllers: [RoleAuthoritiesController],
  providers: [RoleAuthoritiesService],
})
export class RoleAuthoritiesModule {}
