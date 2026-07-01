-- Supabase Multi-Tenant Schema
-- Run this in Supabase SQL Editor

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  google_id TEXT UNIQUE NOT NULL,
  google_name TEXT NOT NULL,
  google_picture_url TEXT,
  language VARCHAR(5) DEFAULT 'de',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- OAuth Tokens (encrypted)
CREATE TABLE oauth_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider VARCHAR(50) NOT NULL,
  access_token TEXT NOT NULL,
  refresh_token TEXT,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, provider)
);

-- Captures (Multi-Tenant)
CREATE TABLE captures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('text', 'voice')),
  title TEXT,
  content TEXT NOT NULL,
  drive_file_id TEXT,
  drive_folder_id TEXT NOT NULL,
  sync_status VARCHAR(20) DEFAULT 'pending',
  sync_error TEXT,
  retry_count INT DEFAULT 0,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- User Settings
CREATE TABLE user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  drive_folder_id TEXT NOT NULL,
  drive_folder_name TEXT NOT NULL,
  drive_folder_path TEXT,
  is_favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Row Level Security (Multi-Tenant Isolation)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE oauth_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE captures ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- Indexes
CREATE INDEX captures_user_id_idx ON captures(user_id);
CREATE INDEX captures_created_at_idx ON captures(created_at DESC);
CREATE INDEX captures_sync_status_idx ON captures(sync_status);
