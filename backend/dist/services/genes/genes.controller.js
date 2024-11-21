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
exports.GenesController = void 0;
const common_1 = require("@nestjs/common");
const genes_service_1 = require("./genes.service");
const create_gene_dto_1 = require("./dto/create-gene.dto");
const update_gene_dto_1 = require("./dto/update-gene.dto");
const class_transformer_1 = require("class-transformer");
const gene_dto_1 = require("./dto/gene.dto");
let GenesController = class GenesController {
    constructor(genesService) {
        this.genesService = genesService;
    }
    async create(createGeneDto) {
        try {
            const result = await this.genesService.create(createGeneDto);
            return (0, class_transformer_1.plainToInstance)(gene_dto_1.default, result);
        }
        catch (error) {
            console.log('Error:', error);
            throw error;
        }
    }
    findAll() {
        return this.genesService
            .findAll()
            .then((items) => items.map((item) => (0, class_transformer_1.plainToInstance)(gene_dto_1.default, item)));
    }
    findOne(id) {
        return (0, class_transformer_1.plainToInstance)(gene_dto_1.default, this.genesService.findOne(id));
    }
    update(id, updateGeneDto) {
        return (0, class_transformer_1.plainToInstance)(gene_dto_1.default, this.genesService.update(id, updateGeneDto));
    }
    remove(id) {
        return (0, class_transformer_1.plainToInstance)(gene_dto_1.default, this.genesService.remove(id));
    }
};
exports.GenesController = GenesController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_gene_dto_1.CreateGeneDto]),
    __metadata("design:returntype", Promise)
], GenesController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], GenesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], GenesController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_gene_dto_1.UpdateGeneDto]),
    __metadata("design:returntype", void 0)
], GenesController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], GenesController.prototype, "remove", null);
exports.GenesController = GenesController = __decorate([
    (0, common_1.Controller)('genes'),
    __metadata("design:paramtypes", [genes_service_1.GenesService])
], GenesController);
//# sourceMappingURL=genes.controller.js.map