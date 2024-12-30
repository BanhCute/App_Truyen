import { CanActivate, ExecutionContext } from '@nestjs/common';
export declare class AuthGuard implements CanActivate {
    constructor();
    canActivate(context: ExecutionContext): Promise<boolean>;
}
