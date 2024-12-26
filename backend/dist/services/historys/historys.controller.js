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
exports.HistorysController = void 0;
const common_1 = require("@nestjs/common");
const historys_service_1 = require("./historys.service");
const create_history_dto_1 = require("./dto/create-history.dto");
const history_dto_1 = require("./dto/history.dto");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
const auth_utils_1 = require("../auth/auth.utils");
let HistorysController = class HistorysController {
    constructor(historysService) {
        this.historysService = historysService;
    }
    create(createHistoryDto, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return (0, class_transformer_1.plainToInstance)(history_dto_1.default, this.historysService.create(createHistoryDto, session.id));
    }
    findAll() {
        return this.historysService
            .findAll()
            .then((items) => items.map((item) => (0, class_transformer_1.plainToInstance)(history_dto_1.default, item)));
    }
    findOne(id) {
        return (0, class_transformer_1.plainToInstance)(history_dto_1.default, this.historysService.findOne(id));
    }
    remove(id, req) {
        const session = (0, auth_utils_1.getSession)(req);
        return (0, class_transformer_1.plainToInstance)(history_dto_1.default, this.historysService.remove(id, session.id));
    }
};
exports.HistorysController = HistorysController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_history_dto_1.CreateHistoryDto, Object]),
    __metadata("design:returntype", void 0)
], HistorysController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], HistorysController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], HistorysController.prototype, "findOne", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], HistorysController.prototype, "remove", null);
exports.HistorysController = HistorysController = __decorate([
    (0, swagger_1.ApiTags)('history'),
    (0, common_1.Controller)('history'),
    __metadata("design:paramtypes", [historys_service_1.HistorysService])
], HistorysController);
//# sourceMappingURL=historys.controller.js.map