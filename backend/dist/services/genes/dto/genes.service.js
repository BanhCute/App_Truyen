"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GenesService = void 0;
const common_1 = require("@nestjs/common");
let GenesService = class GenesService {
    create(createGeneDto) {
        return 'This action adds a new gene';
    }
    findAll() {
        return `This action returns all genes`;
    }
    findOne(id) {
        return `This action returns a #${id} gene`;
    }
    update(id, updateGeneDto) {
        return `This action updates a #${id} gene`;
    }
    remove(id) {
        return `This action removes a #${id} gene`;
    }
};
exports.GenesService = GenesService;
exports.GenesService = GenesService = __decorate([
    (0, common_1.Injectable)()
], GenesService);
//# sourceMappingURL=genes.service.js.map