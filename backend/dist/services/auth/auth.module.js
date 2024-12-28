"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthModule = void 0;
const common_1 = require("@nestjs/common");
const auth_controller_1 = require("./auth.controller");
const jwt_1 = require("@nestjs/jwt");
const github_module_1 = require("../github/github.module");
const jwt_service_1 = require("../jwt/jwt.service");
const config_1 = require("@nestjs/config");
const auth_middleware_1 = require("./auth.middleware");
let AuthModule = class AuthModule {
};
exports.AuthModule = AuthModule;
exports.AuthModule = AuthModule = __decorate([
    (0, common_1.Module)({
        imports: [
            jwt_1.JwtModule.registerAsync({
                imports: [config_1.ConfigModule],
                inject: [config_1.ConfigService],
                useFactory: async (configService) => {
                    return {
                        secret: configService.get('auth')?.jwt?.secret,
                        signOptions: { expiresIn: '3d' },
                    };
                },
                global: true,
            }),
            github_module_1.GithubModule,
            jwt_1.JwtModule,
        ],
        controllers: [auth_controller_1.AuthController],
        providers: [jwt_service_1.JwtAuthService, auth_middleware_1.AuthMiddleware],
        exports: [jwt_service_1.JwtAuthService, auth_middleware_1.AuthMiddleware],
    })
], AuthModule);
//# sourceMappingURL=auth.module.js.map