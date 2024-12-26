"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const auth_module_1 = require("./services/auth/auth.module");
const role_module_1 = require("./services/role/role.module");
const users_module_1 = require("./services/users/users.module");
const cloudinary_module_1 = require("./services/cloudinary/cloudinary.module");
const platform_express_1 = require("@nestjs/platform-express");
const auth_middleware_1 = require("./services/auth/auth.middleware");
const nestjs_form_data_1 = require("nestjs-form-data");
const authorities_module_1 = require("./services/authorities/authorities.module");
const role_authorities_module_1 = require("./services/role-authorities/role-authorities.module");
const app_controller_1 = require("./app.controller");
const app_service_1 = require("./app.service");
const category_module_1 = require("./services/category/category.module");
const database_module_1 = require("./services/database/database.module");
const genes_module_1 = require("./services/genes/genes.module");
const novel_module_1 = require("./services/novel/novel.module");
const config_1 = require("@nestjs/config");
const chapters_module_1 = require("./services/chapters/chapters.module");
const comments_module_1 = require("./services/comments/comments.module");
const configuration_1 = require("./config/configuration");
const google_module_1 = require("./services/google/google.module");
const follows_module_1 = require("./services/follows/follows.module");
const ratings_module_1 = require("./services/ratings/ratings.module");
const historys_module_1 = require("./services/historys/historys.module");
let AppModule = class AppModule {
    configure(consumer) {
        consumer.apply(auth_middleware_1.AuthMiddleware).forRoutes('*');
    }
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: ['.env', '.development.env'],
                cache: true,
                load: [configuration_1.default],
            }),
            cloudinary_module_1.CloudinaryModule,
            category_module_1.CategoryModule,
            database_module_1.DatabaseModule,
            genes_module_1.GenesModule,
            novel_module_1.NovelModule,
            nestjs_form_data_1.NestjsFormDataModule.config({ isGlobal: true, storage: nestjs_form_data_1.MemoryStoredFile }),
            auth_module_1.AuthModule,
            users_module_1.UsersModule,
            role_module_1.RoleModule,
            cloudinary_module_1.CloudinaryModule,
            platform_express_1.MulterModule.register({
                dest: './upload',
            }),
            authorities_module_1.AuthoritiesModule,
            role_authorities_module_1.RoleAuthoritiesModule,
            google_module_1.GoogleModule,
            chapters_module_1.ChaptersModule,
            comments_module_1.CommentsModule,
            follows_module_1.FollowsModule,
            ratings_module_1.RatingsModule,
            historys_module_1.HistorysModule,
        ],
        controllers: [app_controller_1.AppController],
        providers: [app_service_1.AppService],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map