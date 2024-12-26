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

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

const appConfig = () => ({
  port: parseInt(process.env.PORT || '8080'),
  url: {
    frontend: 'http://localhost:3000',
  },
  auth: {
    jwt: {
      secret: process.env.JWT_SECRET as string,
      expiresInSeconds: parseInt(
        process.env.JWT_EXPIRATION_TIME_SECONDS ?? '900',
      ),
    },
    github: {
      clientId: process.env.GITHUB_OAUTH_CLIENT_ID as string,
      clientSecret: process.env.GITHUB_OAUTH_CLIENT_SECRET as string,
      callbackURL: process.env.GITHUB_OAUTH_CALLBACK_URL as string,
    },
    google: {
      clientId: process.env.GOOGLE_OAUTH_CLIENT_ID as string,
      clientSecret: process.env.GOOGLE_OAUTH_CLIENT_SECRET as string,
    },
  },
  cloudinary: {
    secret: process.env.CLOUDINARY_SECRET as string,
    key: process.env.CLOUDINARY_KEY as string,
    cloudName: process.env.CLOUDINARY_CLOUD_NAME as string,
  },
});

export default appConfig;
