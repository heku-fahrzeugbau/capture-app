# Capture App — Multi-Tenant Second Brain Input

Schnelle Text- und Spracherfassung für dein Second Brain (Obsidian, Google Drive, etc.)

## Features (MVP)

- 🎙️ **Sprachaufnahme** → Automatische Transkription (OpenAI Whisper)
- 📝 **Text-Input** → Direkt in Markdown
- 🔐 **Multi-Tenant Auth** → Google OAuth 2.0
- 📁 **Google Drive Integration** → Speichern in dein Drive
- 🗄️ **Supabase PostgreSQL** → Multi-User Database mit RLS
- 🚀 **Next.js PWA** → Online & Offline Support

## Tech Stack

- **Frontend**: Next.js 15, TypeScript, Tailwind CSS
- **Backend**: Next.js API Routes
- **Database**: Supabase (PostgreSQL) mit Row Level Security
- **Auth**: Google OAuth 2.0
- **Voice**: OpenAI Whisper API
- **Storage**: Google Drive API
- **Hosting**: Vercel

## Getting Started

### 1. Clone & Install

```bash
git clone https://github.com/heku-fahrzeugbau/capture-app.git
cd capture-app
npm install
```

### 2. Environment Setup

```bash
cp .env.local.example .env.local
# Add your credentials (already in .env.local if you set up prep)
```

### 3. Database Setup

Run the SQL schema in Supabase (already done if you ran the schema):

```
docs/SUPABASE_SCHEMA.sql
```

### 4. Run Locally

```bash
npm run dev
```

Open http://localhost:3000

## Architecture

### Multi-Tenant Design

```
User A (Google ID: xxx) ──┐
User B (Google ID: yyy) ──┼──→ Supabase PostgreSQL
User C (Google ID: zzz) ──┘
      ↓
   RLS (Row Level Security)
      ↓
Each user sees ONLY their own:
  - Captures
  - OAuth Tokens
  - Settings
```

### Data Flow

```
Text/Voice Input
    ↓
Create Capture (API)
    ↓
Supabase (status: pending)
    ↓
[Future] Upload to Google Drive
    ↓
[Future] n8n Processing
```

## Development Roadmap

### Phase 1 (MVP) ✅
- [x] Multi-Tenant Architecture
- [x] Google OAuth
- [x] Text Capture
- [x] Voice Capture + Whisper
- [x] Supabase Integration

### Phase 2
- [ ] Google Drive Upload
- [ ] Offline Support (IndexedDB + Service Worker)
- [ ] Folder Picker
- [ ] Upload Queue + Retry Logic
- [ ] Error Handling & Toast UI

### Phase 3
- [ ] n8n Integration
- [ ] Automatic Categorization
- [ ] OneNote / OneDrive Support
- [ ] Telegram Bot Integration
- [ ] Web Dashboard

## API Routes

### POST /api/auth/google-callback
Google OAuth callback. Handles signup/signin, token storage.

### POST /api/capture/create
Create a new text or voice capture.

**Body:**
```json
{
  "type": "text" | "voice",
  "title": "My Note",
  "content": "Text content or transcript",
  "metadata": { "duration_seconds": 45 }
}
```

### POST /api/capture/transcribe
Transcribe audio to text via OpenAI Whisper.

**Body:** FormData with `file` (audio blob)

**Response:**
```json
{ "text": "Transcribed text..." }
```

## Security

- ✅ Google OAuth (secure token exchange)
- ✅ Supabase RLS (per-user data isolation)
- ✅ HttpOnly cookies (session tokens)
- ✅ HTTPS only (production)
- ⚠️ TODO: Token encryption in database

## DSGVO Compliance

- ✅ User consent banner (first login)
- ✅ Data stored in EU (Supabase Frankfurt)
- ✅ Privacy Policy
- ⚠️ TODO: GDPR Right to be Forgotten
- ⚠️ TODO: Data Export

## Contributing

Contributions welcome! See CONTRIBUTING.md

## License

MIT — Built with ❤️ for Robin Kollmeier

---

**Questions?** Open an issue or contact @robincodedev
