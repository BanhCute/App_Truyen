"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateGeneDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_gene_dto_1 = require("./create-gene.dto");
class UpdateGeneDto extends (0, swagger_1.PartialType)(create_gene_dto_1.CreateGeneDto) {
}
exports.UpdateGeneDto = UpdateGeneDto;
//# sourceMappingURL=update-gene.dto.js.map