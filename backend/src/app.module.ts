import { Module } from '@nestjs/common';
import { MiddlewareConsumer, NestModule } from '@nestjs/common';
import { AuthModule } from 'src/services/auth/auth.module';
import { RoleModule } from 'src/services/role/role.module';
import { UsersModule } from 'src/services/users/users.module';
import { CloudinaryModule } from './services/cloudinary/cloudinary.module';
import { MulterModule } from '@nestjs/platform-express';
import { AuthMiddleware } from 'src/services/auth/auth.middleware';
import { MemoryStoredFile, NestjsFormDataModule } from 'nestjs-form-data';
import { AuthoritiesModule } from './services/authorities/authorities.module';
import { RoleAuthoritiesModule } from './services/role-authorities/role-authorities.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CategoryModule } from './services/category/category.module';
import { DatabaseModule } from 'src/services/database/database.module';
import { GenesModule } from './services/genes/genes.module';
import { NovelModule } from './services/novel/novel.module';
import { ConfigModule } from '@nestjs/config';
import { ChaptersModule } from './services/chapters/chapters.module';
import { CommentsModule } from './services/comments/comments.module';
import appConfig from 'src/config/configuration';
import { GoogleModule } from 'src/services/google/google.module';
import { FollowsModule } from './services/follows/follows.module';
import { RatingsModule } from './services/ratings/ratings.module';
import { HistorysModule } from './services/historys/historys.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '.development.env'],
      cache: true,
      load: [appConfig],
    }),
    CloudinaryModule,
    CategoryModule,
    DatabaseModule,
    GenesModule,
    NovelModule,
    NestjsFormDataModule.config({ isGlobal: true, storage: MemoryStoredFile }),
    AuthModule,
    UsersModule,
    RoleModule,
    CloudinaryModule,
    MulterModule.register({
      dest: './upload',
    }),
    AuthoritiesModule,
    RoleAuthoritiesModule,
    GoogleModule,
    ChaptersModule,
    CommentsModule,
    FollowsModule,
    RatingsModule,
    HistorysModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(AuthMiddleware).forRoutes('*');
  }
}
