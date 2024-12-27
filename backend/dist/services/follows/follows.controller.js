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
exports.FollowsController = void 0;
const common_1 = require("@nestjs/common");
const follows_service_1 = require("./follows.service");
const create_follow_dto_1 = require("./dto/create-follow.dto");
const follows_dto_1 = require("./dto/follows.dto");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
const auth_utils_1 = require("../auth/auth.utils");
const auth_guard_1 = require("../auth/auth.guard");
let FollowsController = class FollowsController {
    constructor(followsService) {
        this.followsService = followsService;
    }
    create(createFollowDto, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return (0, class_transformer_1.plainToInstance)(follows_dto_1.default, this.followsService.create(createFollowDto, session.id));
    }
    findAll() {
        return this.followsService
            .findAll()
            .then((items) => items.map((item) => (0, class_transformer_1.plainToInstance)(follows_dto_1.default, item)));
    }
    findOne(id) {
        return (0, class_transformer_1.plainToInstance)(follows_dto_1.default, this.followsService.findOne(id));
    }
    remove(id, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return (0, class_transformer_1.plainToInstance)(follows_dto_1.default, this.followsService.remove(id, session.id));
    }
    async removeByNovelId(novelId, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return (0, class_transformer_1.plainToInstance)(follows_dto_1.default, await this.followsService.removeByNovelId(novelId, session.id));
    }
};
exports.FollowsController = FollowsController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_follow_dto_1.CreateFollowDto, Object]),
    __metadata("design:returntype", void 0)
], FollowsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], FollowsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], FollowsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], FollowsController.prototype, "remove", null);
__decorate([
    (0, common_1.Delete)('novel/:novelId'),
    __param(0, (0, common_1.Param)('novelId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", Promise)
], FollowsController.prototype, "removeByNovelId", null);
exports.FollowsController = FollowsController = __decorate([
    (0, swagger_1.ApiTags)('follows'),
    (0, common_1.Controller)('follows'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    __metadata("design:paramtypes", [follows_service_1.FollowsService])
], FollowsController);
//# sourceMappingURL=follows.controller.js.map