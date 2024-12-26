"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateNovelDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_novel_dto_1 = require("./create-novel.dto");
class UpdateNovelDto extends (0, mapped_types_1.PartialType)(create_novel_dto_1.CreateNovelDto) {
}
exports.UpdateNovelDto = UpdateNovelDto;
//# sourceMappingURL=update-novel.dto.js.map