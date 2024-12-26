"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
BigInt.prototype.toJSON = function () {
    return this.toString();
};
const appConfig = () => ({
    port: parseInt(process.env.PORT || '8080'),
    url: {
        frontend: 'http://localhost:3000',
    },
    auth: {
        jwt: {
            secret: process.env.JWT_SECRET,
            expiresInSeconds: parseInt(process.env.JWT_EXPIRATION_TIME_SECONDS ?? '900'),
        },
        github: {
            clientId: process.env.GITHUB_OAUTH_CLIENT_ID,
            clientSecret: process.env.GITHUB_OAUTH_CLIENT_SECRET,
            callbackURL: process.env.GITHUB_OAUTH_CALLBACK_URL,
        },
        google: {
            clientId: process.env.GOOGLE_OAUTH_CLIENT_ID,
            clientSecret: process.env.GOOGLE_OAUTH_CLIENT_SECRET,
        },
    },
    cloudinary: {
        secret: process.env.CLOUDINARY_SECRET,
        key: process.env.CLOUDINARY_KEY,
        cloudName: process.env.CLOUDINARY_CLOUD_NAME,
    },
});
exports.default = appConfig;
//# sourceMappingURL=configuration.js.map