import { Request } from 'express';
import { SessionDto } from 'src/services/auth/dto/session.dto';
export declare function getSessionOrNull(req: Request): SessionDto | null;
export declare function getSession(req: Request): SessionDto;
