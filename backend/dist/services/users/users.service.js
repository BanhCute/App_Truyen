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
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const NotFound_1 = require("../../error/NotFound");
const database_service_1 = require("../database/database.service");
let UsersService = class UsersService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async find(providerId, provider) {
        let user = await this.prisma.account
            .findFirst({
            where: {
                provider,
                providerId,
            },
        })
            .user({
            include: {
                authorities: {
                    select: {
                        authority: {
                            select: {
                                name: true,
                            },
                        },
                    },
                },
                roles: {
                    select: {
                        role: {
                            select: {
                                name: true,
                            },
                        },
                    },
                },
            },
        });
        if (!user) {
            return null;
        }
        const roles = user.roles.map((item) => item.role.name);
        const authorities = user.authorities.map((item) => item.authority.name);
        return { ...user, roles, authorities };
    }
    async create(providerId, provider, { name, profileUrl }) {
        const role = await this.prisma.role.findFirstOrThrow({
            where: { name: 'USER' },
        });
        const user = await this.prisma.user.create({
            data: {
                name: name,
                avatar: profileUrl,
                isDeleted: false,
                isBanned: false,
                roles: {
                    create: {
                        roleId: role.id,
                    },
                },
                accounts: {
                    create: {
                        provider,
                        providerId,
                        createdAt: new Date(),
                    },
                },
            },
        });
        return { ...user, authorities: [], roles: [role.name] };
    }
    async get(id) {
        const user = await this.prisma.user.findFirst({ where: { id } });
        if (!user) {
            throw new NotFound_1.default('id');
        }
        return user;
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], UsersService);
//# sourceMappingURL=users.service.js.map