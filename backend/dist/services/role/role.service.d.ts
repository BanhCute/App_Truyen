import { OnModuleInit } from '@nestjs/common';
import { CreateRoleDto } from './dto/create-role.dto';
import { UpdateRoleDto } from './dto/update-role.dto';
import { DatabaseService } from 'src/services/database/database.service';
export declare class RoleService implements OnModuleInit {
    private prismService;
    constructor(prismService: DatabaseService);
    onModuleInit(): void;
    create(createRoleDto: CreateRoleDto): string;
    findAll(): string;
    findOne(id: number): string;
    update(id: number, updateRoleDto: UpdateRoleDto): string;
    remove(id: number): string;
}
