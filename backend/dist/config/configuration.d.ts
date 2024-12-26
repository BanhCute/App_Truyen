export interface AppConfig {
    port: number;
    'url.frontend'?: string;
    'auth.jwt.secret'?: string;
    'auth.jwt.expiresInSeconds'?: number;
    'auth.github.clientId'?: string;
    'auth.github.clientSecret'?: string;
    'auth.github.callbackURL'?: string;
    'cloudinary.secret': string;
    'cloudinary.key': string;
    'cloudinary.cloudName': string;
}
declare const appConfig: () => {
    port: number;
    url: {
        frontend: string;
    };
    auth: {
        jwt: {
            secret: string;
            expiresInSeconds: number;
        };
        github: {
            clientId: string;
            clientSecret: string;
            callbackURL: string;
        };
        google: {
            clientId: string;
            clientSecret: string;
        };
    };
    cloudinary: {
        secret: string;
        key: string;
        cloudName: string;
    };
};
export default appConfig;
