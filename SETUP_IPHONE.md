# Setup für iPhone Testing — Quick Notes App

## Schritt 1: Repository klonen

```bash
cd ~/Projects  # oder wo du deine Projekte speicherst
git clone https://github.com/heku-fahrzeugbau/capture-app.git
cd capture-app
```

## Schritt 2: Xcode Project erstellen

1. **Xcode öffnen**
   ```bash
   open -a Xcode
   ```

2. **Neues iOS Project**
   - File → New → Project
   - Wähle: **iOS**
   - Template: **App**
   - Next

3. **Project Details ausfüllen**
   - **Product Name:** CaptureApp
   - **Team ID:** (dein Apple Developer Account)
   - **Bundle Identifier:** `de.heku.capture` (wichtig für OAuth!)
   - **Language:** Swift
   - **User Interface:** SwiftUI
   - **Minimum Deployment Target:** iOS 15.0
   - Speichern: Im `capture-app` Ordner

## Schritt 3: Source Files hinzufügen

1. **Finder: capture-app Ordner öffnen**
2. **Xcode: Project Navigator (links) → CaptureApp Ordner → Rechtsklick → "Add Files to CaptureApp"**
3. Wähle: `Sources/CaptureApp/` Ordner
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to target "CaptureApp"
4. **Add**

Deine Dateistruktur sollte jetzt so aussehen:
```
CaptureApp/
├── CaptureApp.swift (oder AppDelegate.swift)
├── Views/
│   ├── HomeView.swift
│   ├── ArchiveView.swift
│   ├── LoginView.swift
│   └── SettingsView.swift
├── Services/
│   ├── GoogleAuthService.swift
│   ├── VoiceService.swift
│   ├── GoogleDriveService.swift
│   ├── OfflineStorageService.swift
│   └── SyncEngine.swift
├── Models/
│   ├── Note.swift
│   └── NoteEntity+CoreData.swift
└── Utilities/
    └── MarkdownGenerator.swift
```

## Schritt 4: Info.plist konfigurieren

1. **Xcode: Project → CaptureApp → Info**
2. **Neue Keys hinzufügen:**

```xml
CFBundleURLTypes = (
  {
    CFBundleURLSchemes = (de.heku.capture)
  }
)

NSMicrophoneUsageDescription = "Die App benötigt Mikrofonzugriff für Sprachaufnahmen."

NSLocalNetworkUsageDescription = "Die App benötigt Netzwerkzugriff für Google Drive."
```

## Schritt 5: Capabilities aktivieren

1. **Xcode: Project → CaptureApp → Signing & Capabilities**
2. **Klick: "+ Capability"**
3. **Aktiviere:**
   - Microphone
   - Background Modes (Optional, für spätere Auto-Sync)

## Schritt 6: Core Data Model erstellen

1. **File → New → File**
2. Wähle: **Data Model**
3. Name: `CaptureApp`
4. **Create**

5. **Im Data Model Editor:**
   - Klick: **Add Entity**
   - Name: `NoteEntity`
   - Attributes hinzufügen:
     ```
     - id: UUID (required)
     - title: String (required)
     - content: String (required)
     - timestamp: Date (required)
     - syncStatus: String (required)
     - filename: String (required)
     - googleDriveFileID: String (optional)
     - errorMessage: String (optional)
     - retryCount: Int16 (default: 0)
     ```

6. **Build testen:**
   ```bash
   ⌘ + B (Build)
   ```

## Schritt 7: Google OAuth konfigurieren

### 7.1 Google Cloud Console

1. Gehe zu: https://console.cloud.google.com
2. **Erstelle ein neues Projekt:** "Quick Notes App"
3. Warte auf Erstellung

### 7.2 OAuth 2.0 Client ID

1. **APIs & Services** → **Library**
2. Suche: `Google Drive API`
3. **Enable**

4. **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
5. Wähle: **iOS application**
6. Gib ein:
   - **Name:** Quick Notes App
   - **Bundle ID:** `de.heku.capture` (muss identisch sein!)
   - **App Schemes:** `de.heku.capture` (optional)
7. **Create**

### 7.3 Client ID in Code eintragen

1. **Xcode: Services → GoogleAuthService.swift**
2. Suche: `let clientID = "YOUR_GOOGLE_CLIENT_ID"`
3. Ersetze mit deiner echten Client ID (von Google Cloud Console)

### 7.4 Redirect URI konfigurieren

In Google Cloud Console:
1. Bearbeite deine iOS OAuth Client ID
2. Unter **Authorized redirect URIs** hinzufügen:
   ```
   de.heku.capture://oauth
   ```

## Schritt 8: iPhone verbinden

1. **USB-Kabel:** iPhone mit Mac verbinden
2. **Vertrauen:** iPhone: "Trust this computer" → Trust
3. **Xcode:** 
   - Top-Center: Device-Selector
   - Wähle dein iPhone

## Schritt 9: App deployen

1. **Xcode: ⌘ + R (Run)**
2. Xcode baut die App und deployt sie auf dein iPhone
3. App startet automatisch

## Schritt 10: Erste Nutzung

1. **App öffnet → LoginView angezeigt**
2. **Klick: "Mit Google verbinden"**
3. **Browser öffnet Google-Login**
4. **Melde dich mit deinem Google-Account an**
5. **Erlaube Zugriff auf Google Drive**
6. **Zurück zur App → HomeView**

7. **Folder wählen:**
   - Hamburger Menu (oben links)
   - Settings
   - "Zielordner" → Wähle einen Ordner aus
   - Zurück

8. **Erste Notiz erstellen:**
   - Text eingeben: "Test Notiz"
   - Oder Voice-Button drücken und sprechen
   - Send-Button drücken
   - Notiz wird lokal gespeichert

9. **Archive öffnen (Swipe right oder ArchiveView)**
   - Notiz sollte mit "Ausstehend" Status angezeigt werden

10. **Synchronisierung testen:**
    - Settings → "Jetzt Synchronisieren" Button
    - Status sollte zu "Synchronisierung" → "Synchronisiert" ändern
    - Gehe zu Google Drive → Überprüfe ob Datei dort ist

## Troubleshooting

### Build Error: "Module not found"
- **Fix:** Clean Build Folder (⇧ + ⌘ + K)
- Rebuild (⌘ + B)

### App crashed bei Launch
- **Xcode Console anschauen** für Error Messages
- Häufig: Missing Core Data Model oder Auth Token Fehler

### Google Login funktioniert nicht
- **Check:** Bundle ID identisch in Xcode und Google Cloud Console?
- **Check:** Client ID korrekt in GoogleAuthService.swift?
- **Check:** Redirect URI konfiguriert?

### Notizen speichern sich nicht
- **Check:** Microphone Permission granted?
- **Check:** Core Data Model erstellt?
- Xcode Console: Fehler-Messages lesen

### Upload zu Google Drive schlägt fehl
- **Check:** Du bist eingeloggt (Settings)?
- **Check:** Folder ausgewählt?
- **Check:** Netzwerk erreichbar?
- **Check:** Retry-Logik funktioniert (warte 30 Sekunden oder Manual Sync)

## Performance Tipps

- **Erste App Start:** Kann 2-3 Sekunden dauern (Core Data Setup)
- **Voice Recording:** Sollte Echtzeit-Transkription zeigen
- **Archive mit 100+ Notizen:** Scroll kann etwas laggy sein (für später optimieren)

## Nächste Schritte

Sobald du die App getestet hast:
1. Schreib eine Nachricht mit deinem Feedback
2. Screenshots für App Store Marketing
3. Dann können wir:
   - Fehler beheben (Bugs)
   - UI polishen (feiner machen)
   - App Store vorbereiten

Viel Erfolg beim Testen! 🎉
