"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSessionOrNull = getSessionOrNull;
exports.getSession = getSession;
const common_1 = require("@nestjs/common");
function getSessionOrNull(req) {
    const user = req.user;
    if (!user) {
        return null;
    }
    return {
        id: user.id,
        name: user.name,
        avatar: user.avatar,
        authorities: user.authorities,
        roles: user.roles,
    };
}
function getSession(req) {
    const user = req.user;
    if (!user) {
        throw new common_1.UnauthorizedException();
    }
    return {
        id: user.id,
        name: user.name,
        avatar: user.avatar,
        authorities: user.authorities,
        roles: user.roles,
    };
}
//# sourceMappingURL=auth.utils.js.map