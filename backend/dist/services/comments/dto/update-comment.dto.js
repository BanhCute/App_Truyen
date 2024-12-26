"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateCommentDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_comment_dto_1 = require("./create-comment.dto");
class UpdateCommentDto extends (0, swagger_1.PartialType)(create_comment_dto_1.CreateCommentDto) {
}
exports.UpdateCommentDto = UpdateCommentDto;
//# sourceMappingURL=update-comment.dto.js.map