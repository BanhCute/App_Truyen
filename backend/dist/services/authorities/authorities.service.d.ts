import { OnModuleInit } from '@nestjs/common';
import { DatabaseService } from 'src/services/database/database.service';
export declare class AuthoritiesService implements OnModuleInit {
    private DatabaseService;
    constructor(DatabaseService: DatabaseService);
    onModuleInit(): void;
}
