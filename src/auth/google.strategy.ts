import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor() {
    const googleClientId = process.env.GOOGLE_CLIENT_ID ?? "";
    const googleClientSecret = process.env.GOOGLE_CLIENT_SECRET ?? "";
    const jwtSecret = process.env.JWT_SECRET ?? "";
    const googleCallback = process.env.GOOGLE_CALLBACK ?? 'http://localhost:3000/auth/google/redirect';

    console.log('GOOGLE_CLIENT_ID:', googleClientId);
    console.log('GOOGLE_CLIENT_SECRET:', googleClientSecret);
    console.log('GOOGLE_CALLBACK:', googleCallback);
    
    super({
      clientID: googleClientId,
      clientSecret: googleClientSecret,
      callbackURL: googleCallback,
      scope: ['email', 'profile'],
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: any,
    done: VerifyCallback,
  ): Promise<any> {
    console.log('Access Token:', accessToken);
    console.log('Refresh Token:', refreshToken);
    console.log('Profile:', profile);

    const { name, emails, photos } = profile;

    const user = {
      email: emails[0].value,
      displayName: `${name.givenName} ${name.familyName}`,
      photos: photos,
      accessToken,
    };

    done(null, user);
  }
}
