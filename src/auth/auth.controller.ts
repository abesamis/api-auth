import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('show')
  async show(@Req() req): Promise<void> {
    const googleClientId = process.env.GOOGLE_CLIENT_ID ?? "";
    const googleClientSecret = process.env.GOOGLE_CLIENT_SECRET ?? "";
    const jwtSecret = process.env.JWT_SECRET ?? "";
    const googleCallback = process.env.GOOGLE_CALLBACK ?? 'http://localhost:3000/auth/google/redirect';

    console.log('GOOGLE_CLIENT_ID:', googleClientId);
    console.log('GOOGLE_CLIENT_SECRET:', googleClientSecret);
    console.log('GOOGLE_CALLBACK:', googleCallback);

    return process.env;
  }

  @Get('google')
  @UseGuards(AuthGuard('google'))
  async googleAuth(@Req() req): Promise<void> {
    // Initiates Google login
  }

  @Get('google/redirect')
  @UseGuards(AuthGuard('google'))
  async googleAuthRedirect(@Req() req): Promise<any> {
    // Handles Google OAuth2 callback and checks the email in the database
    return this.authService.googleLogin(req);
  }
}
