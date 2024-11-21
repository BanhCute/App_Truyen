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
Object.defineProperty(exports, "__esModule", { value: true });
exports.GenesService = void 0;
const common_1 = require("@nestjs/common");
const database_service_1 = require("../database/database.service");
let GenesService = class GenesService {
    constructor(databaseService) {
        this.databaseService = databaseService;
        console.log('GenesService initialized');
    }
    create(createGeneDto) {
        return this.databaseService.genes.create({
            data: createGeneDto,
        });
    }
    async findAll() {
        console.log('Finding all genes');
        const result = await this.databaseService.genes.findMany();
        console.log('Found genes:', result);
        return result;
    }
    findOne(id) {
        return this.databaseService.genes.findUnique({
            where: { id },
        });
    }
    update(id, updateGeneDto) {
        return this.databaseService.genes.update({
            where: { id },
            data: updateGeneDto,
        });
    }
    remove(id) {
        return this.databaseService.genes.delete({
            where: { id },
        });
    }
};
exports.GenesService = GenesService;
exports.GenesService = GenesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [database_service_1.DatabaseService])
], GenesService);
//# sourceMappingURL=genes.service.js.map