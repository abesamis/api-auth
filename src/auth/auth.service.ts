import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  async googleLogin(req): Promise<any> {
    if (!req.user) {
      throw new UnauthorizedException('No user data from Google');
    }

    const { email, displayName } = req.user;

    // Check if the user exists in the database
    let user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      // Optional: Create a new user if they don't exist
      user = await this.prisma.user.create({
        data: {
          email,
          password: '', // Leave empty for Google OAuth users
        },
      });
    }

    return {
      message: 'Google login successful',
      user: {
        id: user.id,
        email: user.email,
        createdAt: user.createdAt,
      },
    };
  }
}
