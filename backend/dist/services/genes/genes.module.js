"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GenesModule = void 0;
const common_1 = require("@nestjs/common");
const genes_service_1 = require("./genes.service");
const genes_controller_1 = require("./genes.controller");
const database_service_1 = require("../database/database.service");
let GenesModule = class GenesModule {
};
exports.GenesModule = GenesModule;
exports.GenesModule = GenesModule = __decorate([
    (0, common_1.Module)({
        controllers: [genes_controller_1.GenesController],
        providers: [genes_service_1.GenesService, database_service_1.DatabaseService],
    })
], GenesModule);
//# sourceMappingURL=genes.module.js.map