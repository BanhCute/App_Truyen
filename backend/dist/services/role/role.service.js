"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RoleService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../database/database.service");
const lodash_1 = require("lodash");
const defaultRoles = [
    {
        id: 1,
        name: 'USER',
        description: 'User role',
    },
    {
        id: 2,
        name: 'RECRUITER',
        description: 'Recruiter role',
    },
    {
        id: 3,
        name: 'CANDIDATE',
        description: 'Candidate role',
    },
    {
        id: 4,
        name: 'EMPLOYEE',
        description: 'Employee role',
    },
    {
        id: 5,
        name: 'ADMIN',
        description: 'Admin role',
    },
];
let RoleService = class RoleService {
    constructor(prismService) {
        this.prismService = prismService;
    }
    onModuleInit() {
        defaultRoles.forEach(async (role) => {
            await this.prismService.role.upsert({
                where: { id: role.id },
                create: (0, lodash_1.omit)(role, ['id']),
                update: (0, lodash_1.omit)(role, ['id']),
            });
        });
    }
    create(createRoleDto) {
        return 'This action adds a new role';
    }
    findAll() {
        return `This action returns all role`;
    }
    findOne(id) {
        return `This action returns a #${id} role`;
    }
    update(id, updateRoleDto) {
        return `This action updates a #${id} role`;
    }
    remove(id) {
        return `This action removes a #${id} role`;
    }
};
exports.RoleService = RoleService;
exports.RoleService = RoleService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], RoleService);
//# sourceMappingURL=role.service.js.map