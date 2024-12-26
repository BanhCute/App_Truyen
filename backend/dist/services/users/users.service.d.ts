import { Prisma, User } from '@prisma/client';
import { DatabaseService } from 'src/services/database/database.service';
import { AuthProvider } from 'src/types/auth';
type UserWithAuthoritiesAndRoles = Prisma.UserGetPayload<{}> & {
    roles: string[];
    authorities: string[];
};
export declare class UsersService {
    private prisma;
    constructor(prisma: DatabaseService);
    find(providerId: string, provider: AuthProvider): Promise<UserWithAuthoritiesAndRoles | null>;
    create(providerId: string, provider: AuthProvider, { name, profileUrl }: {
        name: string;
        profileUrl: string;
    }): Promise<UserWithAuthoritiesAndRoles>;
    get(id: number): Promise<User>;
}
export {};
