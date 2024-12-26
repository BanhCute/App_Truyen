"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("@nestjs/common");
class NotFound extends common_1.NotFoundException {
    constructor(...fields) {
        super({
            fields,
        });
    }
}
exports.default = NotFound;
//# sourceMappingURL=NotFound.js.map