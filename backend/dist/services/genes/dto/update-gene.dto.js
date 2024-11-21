"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateGeneDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_gene_dto_1 = require("./create-gene.dto");
class UpdateGeneDto extends (0, mapped_types_1.PartialType)(create_gene_dto_1.CreateGeneDto) {
}
exports.UpdateGeneDto = UpdateGeneDto;
//# sourceMappingURL=update-gene.dto.js.map