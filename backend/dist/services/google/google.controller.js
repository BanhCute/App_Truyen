"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GoogleOauthController = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const google_auth_library_1 = require("google-auth-library");
const users_service_1 = require("../users/users.service");
const jwt_service_1 = require("../jwt/jwt.service");
const class_transformer_1 = require("class-transformer");
const google_auth_dto_1 = require("./google.auth.dto");
let GoogleOauthController = class GoogleOauthController {
    constructor(configService, usersService, jwtService) {
        this.configService = configService;
        this.usersService = usersService;
        this.jwtService = jwtService;
        this.google = new google_auth_library_1.OAuth2Client(configService.get('auth.google.clientId', { infer: true }), configService.get('auth.google.clientId', { infer: true }));
    }
    async googleAuthCallback(req) {
        const accessToken = req.body.idToken;
        const ticket = await this.google.verifyIdToken({
            idToken: accessToken,
            audience: [
                this.configService.getOrThrow('auth.google.clientId', {
                    infer: true,
                }),
            ],
        });
        const data = ticket.getPayload();
        if (!data) {
            throw new common_1.HttpException('Invalid token', 400);
        }
        const { sub, name, picture } = data;
        let user = await this.usersService.find(sub, 'google');
        if (!user) {
            user = await this.usersService.create(sub, 'google', {
                name: name,
                profileUrl: picture,
            });
        }
        return (0, class_transformer_1.plainToInstance)(google_auth_dto_1.GoogleAuthResponse, {
            ...this.jwtService.login(user),
            user: { ...user },
        });
    }
};
exports.GoogleOauthController = GoogleOauthController;
__decorate([
    (0, common_1.Post)(''),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], GoogleOauthController.prototype, "googleAuthCallback", null);
exports.GoogleOauthController = GoogleOauthController = __decorate([
    (0, common_1.Controller)('auth/google'),
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService,
        users_service_1.UsersService,
        jwt_service_1.JwtAuthService])
], GoogleOauthController);
//# sourceMappingURL=google.controller.js.map