// Multi-Tenant Capture App Types

export interface User {
  id: string;
  email: string;
  google_id: string;
  google_name: string;
  google_picture_url?: string;
  language: 'de' | 'en';
  created_at: string;
  updated_at: string;
}

export interface OAuthToken {
  id: string;
  user_id: string;
  provider: 'google';
  access_token: string; // encrypted
  refresh_token: string; // encrypted
  expires_at: string;
  created_at: string;
}

export interface Capture {
  id: string;
  user_id: string;
  type: 'text' | 'voice';
  title: string;
  content: string;
  drive_file_id?: string;
  drive_folder_id: string;
  sync_status: 'pending' | 'syncing' | 'synced' | 'error';
  sync_error?: string;
  retry_count: number;
  created_at: string;
  updated_at: string;
  metadata?: {
    transcript_original?: string;
    duration_seconds?: number;
    language?: string;
  };
}

export interface UserSettings {
  id: string;
  user_id: string;
  drive_folder_id: string;
  drive_folder_name: string;
  drive_folder_path: string;
  is_favorite: boolean;
  created_at: string;
  updated_at: string;
}

export interface AppState {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  selectedFolder: {
    id: string;
    name: string;
    path: string;
  } | null;
}

export interface AuthSession {
  user_id: string;
  email: string;
  google_id: string;
  iat: number;
  exp: number;
}
