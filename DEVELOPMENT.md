# Development Guide — Quick Notes App

## Project Structure

```
Sources/CaptureApp/
├── App.swift              (Einstiegspunkt)
├── ContentView.swift      (Main UI)
├── Models/
│   └── Note.swift         (Data model für Notizen)
├── Services/
│   ├── GoogleDriveService.swift    (OAuth + Upload)
│   ├── VoiceService.swift          (Speech-to-Text)
│   └── OfflineStorageService.swift (Core Data)
├── Views/
│   ├── HomeView.swift     (Recorder Screen)
│   ├── ArchiveView.swift  (Notes Grid)
│   └── SettingsView.swift (Settings Modal)
└── Utilities/
    └── (Helper extensions, constants)
```

## Development Steps (Phase 1)

### Week 1: Foundation
- [ ] Xcode Project erstellen (iOS 15+, Swift)
- [ ] Google Drive OAuth implementieren
- [ ] Folder Picker UI bauen
- [ ] Settings Screen Grundstruktur

### Week 2: Input & Storage
- [ ] Voice Recording (SpeechAnalyzer)
- [ ] Text Input
- [ ] Core Data Setup
- [ ] Markdown Generator
- [ ] Note Model testen

### Week 3: Sync & Archive
- [ ] Offline Queue (Core Data)
- [ ] Sync Engine (Upload + Retry)
- [ ] Archive View (Kachel-Grid)
- [ ] Search implementieren

### Week 4: Polish
- [ ] Dark/Light Mode
- [ ] Error Handling
- [ ] UI Testing
- [ ] Performance optimieren

## Important Links

- **Design System:** `04_projekte/quick-notes-app/UI-DESIGN.md`
- **Architektur:** `04_projekte/quick-notes-app/ARCHITEKTUR.md`
- **Google Drive API:** https://developers.google.com/drive/api/guides/about-sdk
- **Speech Framework:** https://developer.apple.com/documentation/speech
- **Core Data:** https://developer.apple.com/documentation/coredata

## Testing

```bash
# Run unit tests
⌘ + U in Xcode

# Run app on simulator
⌘ + R in Xcode

# Clean build
⇧ + ⌘ + K
```

## Environment Setup

1. **Google Cloud Console:**
   - Create iOS OAuth 2.0 Client ID
   - Add Bundle ID (e.g., `de.heku.capture`)
   - Download `GoogleService-Info.plist`

2. **Xcode:**
   - Add `GoogleService-Info.plist` to project
   - Enable Speech framework in capabilities
   - Set deployment target to iOS 15+

## Commit Convention

```
feat: Add voice recording
fix: Resolve sync error
docs: Update README
test: Add unit tests for Note model
chore: Update dependencies
```

Format: `type: brief description`

## Questions?

Check the architecture docs or create an issue on GitHub.
