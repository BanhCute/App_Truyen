"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChaptersModule = void 0;
const common_1 = require("@nestjs/common");
const chapters_service_1 = require("./chapters.service");
const chapters_controller_1 = require("./chapters.controller");
const database_service_1 = require("../database/database.service");
let ChaptersModule = class ChaptersModule {
};
exports.ChaptersModule = ChaptersModule;
exports.ChaptersModule = ChaptersModule = __decorate([
    (0, common_1.Module)({
        controllers: [chapters_controller_1.ChaptersController],
        providers: [chapters_service_1.ChaptersService, database_service_1.DatabaseService],
    })
], ChaptersModule);
//# sourceMappingURL=chapters.module.js.map