import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { v4 as uuidv4 } from 'uuid';

const GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token';
const GOOGLE_USERINFO_URL = 'https://www.googleapis.com/oauth2/v2/userinfo';

export async function POST(request: NextRequest) {
  try {
    const { code, state } = await request.json();

    if (!code) {
      return NextResponse.json(
        { error: 'Missing authorization code' },
        { status: 400 }
      );
    }

    // 1. Exchange code for Google tokens
    const tokenResponse = await fetch(GOOGLE_TOKEN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID!,
        client_secret: process.env.GOOGLE_CLIENT_SECRET!,
        code,
        grant_type: 'authorization_code',
        redirect_uri: `${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/api/auth/google-callback`,
      }),
    });

    const tokens = await tokenResponse.json();

    if (tokens.error) {
      return NextResponse.json(
        { error: tokens.error_description },
        { status: 400 }
      );
    }

    // 2. Get user info from Google
    const userResponse = await fetch(GOOGLE_USERINFO_URL, {
      headers: { Authorization: `Bearer ${tokens.access_token}` },
    });

    const googleUser = await userResponse.json();

    // 3. Check if user exists in Supabase
    let user = await supabaseAdmin
      .from('users')
      .select('id')
      .eq('google_id', googleUser.id)
      .single();

    if (user.error && user.error.code !== 'PGRST116') {
      throw user.error;
    }

    let userId = user.data?.id;

    // 4. If user doesn't exist, create new user
    if (!user.data) {
      const newUser = await supabaseAdmin
        .from('users')
        .insert({
          id: uuidv4(),
          google_id: googleUser.id,
          email: googleUser.email,
          google_name: googleUser.name,
          google_picture_url: googleUser.picture,
          language: 'de',
        })
        .select('id')
        .single();

      if (newUser.error) throw newUser.error;
      userId = newUser.data.id;
    }

    // 5. Store OAuth tokens
    await supabaseAdmin.from('oauth_tokens').upsert({
      id: uuidv4(),
      user_id: userId,
      provider: 'google',
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token || '',
      expires_at: new Date(Date.now() + tokens.expires_in * 1000).toISOString(),
    });

    // 6. Create session token
    const sessionToken = Buffer.from(
      JSON.stringify({
        user_id: userId,
        email: googleUser.email,
        google_id: googleUser.id,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60,
      })
    ).toString('base64');

    const response = NextResponse.json(
      { success: true, session_token: sessionToken },
      { status: 200 }
    );

    response.cookies.set('session_token', sessionToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 7 * 24 * 60 * 60,
    });

    return response;
  } catch (error) {
    console.error('Auth error:', error);
    return NextResponse.json(
      { error: 'Authentication failed' },
      { status: 500 }
    );
  }
}
