import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import { v4 as uuidv4 } from 'uuid';

export async function POST(request: NextRequest) {
  try {
    const sessionToken = request.cookies.get('session_token')?.value;
    if (!sessionToken) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { type, title, content, metadata } = await request.json();
    const decoded = JSON.parse(
      Buffer.from(sessionToken, 'base64').toString('utf-8')
    );
    const userId = decoded.user_id;

    const { data: settings } = await supabaseAdmin
      .from('user_settings')
      .select('drive_folder_id')
      .eq('user_id', userId)
      .single();

    const driveFolderId = settings?.drive_folder_id || 'root';

    const { error } = await supabaseAdmin
      .from('captures')
      .insert({
        id: uuidv4(),
        user_id: userId,
        type,
        title,
        content,
        drive_folder_id: driveFolderId,
        sync_status: 'pending',
        metadata: metadata || {},
      });

    if (error) throw error;

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error) {
    console.error('Error:', error);
    return NextResponse.json({ error: 'Failed' }, { status: 500 });
  }
}
