import { JwtService } from '@nestjs/jwt';
import { SessionDto } from 'src/services/auth/dto/session.dto';
export declare class JwtAuthService {
    private jwtService;
    constructor(jwtService: JwtService);
    login(user: SessionDto): {
        accessToken: string;
    };
}
