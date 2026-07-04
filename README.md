# Quick Notes App — iOS

Schnelle Notizen-App für Voice-to-Text und Text-Input mit direktem Upload zu Google Drive.

## Setup

### Voraussetzungen
- macOS 12+
- Xcode 15+
- iOS 15+

### Lokales Setup

1. **Repository clonen:**
   ```bash
   git clone https://github.com/heku-fahrzeugbau/capture-app.git
   cd capture-app
   ```

2. **Xcode Projekt öffnen:**
   ```bash
   open CaptureApp.xcodeproj
   ```
   
   Falls `.xcodeproj` nicht existiert: Xcode manuell öffnen → File → New → Project → iOS App.

3. **Google Drive OAuth konfigurieren:**
   - Google Cloud Console: https://console.cloud.google.com
   - OAuth 2.0 Client ID (iOS app) erstellen
   - Bundle ID: `de.heku.capture` (oder ähnlich)
   - Client ID in `GoogleService-Info.plist` eintragen

4. **Build & Run:**
   ```
   ⌘ + R im Xcode
   ```

## Architektur

- **Plattform:** iOS 15+ (Swift)
- **UI:** SwiftUI
- **Voice:** Apple SpeechAnalyzer (WWDC 2025)
- **Offline DB:** Core Data
- **Cloud:** Google Drive API (OAuth 2.0)

Siehe `../04_projekte/quick-notes-app/ARCHITEKTUR.md` für Details.

## Projekt-Status

- Phase 1 (MVP): In Entwicklung
- OAuth Setup: TODO
- Voice Recording: TODO
- Archive View: TODO

## Kontakt

Robin Kollmeier (@heku)
