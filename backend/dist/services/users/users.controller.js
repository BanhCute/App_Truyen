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
exports.UsersController = void 0;
const common_1 = require("@nestjs/common");
const class_transformer_1 = require("class-transformer");
const auth_utils_1 = require("../auth/auth.utils");
const users_service_1 = require("./users.service");
const user_response_1 = require("./dto/user.response");
const session_dto_1 = require("../auth/dto/session.dto");
let UsersController = class UsersController {
    constructor(userService) {
        this.userService = userService;
    }
    getSession(req) {
        const session = (0, auth_utils_1.getSessionOrNull)(req);
        if (session === null) {
            return null;
        }
        return (0, class_transformer_1.plainToInstance)(session_dto_1.SessionResponseDto, {
            ...session,
            rolePicked: !session.roles.some((role) => role === 'CANDIDATE' || role === 'RECRUITER'),
        });
    }
    get(id) {
        return (0, class_transformer_1.plainToInstance)(user_response_1.UserResponse, this.userService.get(id));
    }
};
exports.UsersController = UsersController;
__decorate([
    (0, common_1.Get)('/session'),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", session_dto_1.SessionResponseDto)
], UsersController.prototype, "getSession", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "get", null);
exports.UsersController = UsersController = __decorate([
    (0, common_1.Controller)('users'),
    __metadata("design:paramtypes", [users_service_1.UsersService])
], UsersController);
//# sourceMappingURL=users.controller.js.map