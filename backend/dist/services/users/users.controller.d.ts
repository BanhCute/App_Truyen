import { Request } from 'express';
import { UsersService } from 'src/services/users/users.service';
import { UserResponse } from 'src/services/users/dto/user.response';
import { SessionResponseDto } from 'src/services/auth/dto/session.dto';
export declare class UsersController {
    private readonly userService;
    constructor(userService: UsersService);
    getSession(req: Request): SessionResponseDto | null;
    get(id: number): UserResponse;
}
