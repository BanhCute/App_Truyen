"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateHistoryDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_history_dto_1 = require("./create-history.dto");
class UpdateHistoryDto extends (0, swagger_1.PartialType)(create_history_dto_1.CreateHistoryDto) {
}
exports.UpdateHistoryDto = UpdateHistoryDto;
//# sourceMappingURL=update-history.dto.js.map