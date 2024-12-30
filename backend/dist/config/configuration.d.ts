export interface AppConfig {
    port: number;
    url: {
        frontend: string;
    };
    database: {
        url: string;
    };
    auth: {
        jwt: {
            secret: string;
            expiresIn: string;
        };
        google: {
            clientId: string;
        };
        github: {
            clientId: string;
            clientSecret: string;
            callbackURL: string;
        };
    };
    cloudinary: {
        cloudName: string;
        apiKey: string;
        apiSecret: string;
    };
}
declare const _default: () => {
    port: number;
    url: {
        frontend: string;
    };
    database: {
        url: string;
    };
    auth: {
        jwt: {
            secret: string;
            expiresIn: string;
        };
        google: {
            clientId: string;
        };
        github: {
            clientId: string;
            clientSecret: string;
            callbackURL: string;
        };
    };
    cloudinary: {
        cloudName: string;
        apiKey: string;
        apiSecret: string;
    };
};
export default _default;
