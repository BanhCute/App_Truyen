"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateFollowDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_follow_dto_1 = require("./create-follow.dto");
class UpdateFollowDto extends (0, swagger_1.PartialType)(create_follow_dto_1.CreateFollowDto) {
}
exports.UpdateFollowDto = UpdateFollowDto;
//# sourceMappingURL=update-follow.dto.js.map