"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = () => ({
    port: parseInt(process.env.PORT, 10) || 3000,
    url: {
        frontend: process.env.FRONTEND_URL || 'http://localhost:3000',
    },
    database: {
        url: process.env.DATABASE_URL,
    },
    auth: {
        jwt: {
            secret: process.env.JWT_SECRET,
            expiresIn: process.env.JWT_EXPIRATION_TIME_SECONDS
                ? `${process.env.JWT_EXPIRATION_TIME_SECONDS}s`
                : '3d',
        },
        google: {
            clientId: process.env.GOOGLE_OAUTH_CLIENT_ID,
        },
        github: {
            clientId: process.env.GITHUB_OAUTH_CLIENT_ID,
            clientSecret: process.env.GITHUB_OAUTH_CLIENT_SECRET,
            callbackURL: process.env.GITHUB_OAUTH_CALLBACK_URL,
        },
    },
    cloudinary: {
        cloudName: process.env.CLOUDINARY_CLOUD_NAME,
        apiKey: process.env.CLOUDINARY_KEY,
        apiSecret: process.env.CLOUDINARY_SECRET,
    },
});
//# sourceMappingURL=configuration.js.map