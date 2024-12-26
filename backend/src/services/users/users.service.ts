import { Injectable } from '@nestjs/common';

import { Prisma, User } from '@prisma/client';
import NotFound from 'src/error/NotFound';
import { DatabaseService } from 'src/services/database/database.service';
import { AuthProvider } from 'src/types/auth';

type UserWithAuthoritiesAndRoles = Prisma.UserGetPayload<{}> & {
  roles: string[];
  authorities: string[];
};

@Injectable()
export class UsersService {
  constructor(private prisma: DatabaseService) {}

  async find(
    providerId: string,
    provider: AuthProvider,
  ): Promise<UserWithAuthoritiesAndRoles | null> {
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

  async create(
    providerId: string,
    provider: AuthProvider,
    { name, profileUrl }: { name: string; profileUrl: string },
  ): Promise<UserWithAuthoritiesAndRoles> {
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

  async get(id: number): Promise<User> {
    const user = await this.prisma.user.findFirst({ where: { id } });

    if (!user) {
      throw new NotFound('id');
    }

    return user;
  }
}
