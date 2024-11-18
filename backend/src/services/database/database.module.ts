import { Global, Module } from '@nestjs/common';
import { DatabaseService } from 'src/services/database/database.service';

@Global()
@Module({
  providers: [DatabaseService],
  exports: [DatabaseService],
})
export class DatabaseModule {}
