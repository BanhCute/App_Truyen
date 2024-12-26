"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("@nestjs/common");
class Conflict extends common_1.ConflictException {
    constructor(...fields) {
        super({
            fields,
        });
    }
}
exports.default = Conflict;
//# sourceMappingURL=Conflict.js.map