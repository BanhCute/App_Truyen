"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateChapterDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_chapter_dto_1 = require("./create-chapter.dto");
class UpdateChapterDto extends (0, mapped_types_1.PartialType)(create_chapter_dto_1.CreateChapterDto) {
}
exports.UpdateChapterDto = UpdateChapterDto;
//# sourceMappingURL=update-chapter.dto.js.map