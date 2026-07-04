# Setup für Windows + Flutter — Quick Notes App

Kompletter Guide zum Entwickeln auf Windows PC.

## Schritt 1: Flutter installieren (30 min)

### 1.1 Flutter SDK herunterladen
1. Gehe zu: https://flutter.dev/docs/get-started/install/windows
2. Lade **Flutter SDK** herunter (z.B. `flutter_windows_3.x.x-stable.zip`)
3. Entpacke in: `C:\flutter` oder `C:\src\flutter`
4. **Wichtig:** Kein Leerzeichen im Pfad!

### 1.2 Flutter zu PATH hinzufügen
1. **Windows-Suchleiste:** "Umgebungsvariablen"
2. Klick: **"Umgebungsvariablen bearbeiten"**
3. **Neue Benutzervariable hinzufügen:**
   - Name: `PATH`
   - Wert: `C:\flutter\bin` (anpassen, falls anders)
4. **OK** → **OK** → **OK**
5. **CMD neu öffnen** und testen:
   ```bash
   flutter --version
   ```
   Sollte Version anzeigen ✅

### 1.3 Flutter Doctor (alle Dependencies checken)
```bash
flutter doctor
```

Folgende sollten ✅ sein:
- ✅ Flutter SDK
- ✅ Windows version
- ✅ Visual Studio (oder VS Code)

Falls ❌: `flutter doctor --android-licenses` akzeptieren

---

## Schritt 2: Android Studio / Emulator (20 min)

### 2.1 Android Studio installieren
1. Gehe zu: https://developer.android.com/studio
2. Downloade **Android Studio**
3. **Install** → akzeptiere alle Defaults
4. Nach Installation: **Configure** → **Device Manager**

### 2.2 Android Emulator erstellen
1. **Device Manager** öffnen
2. Klick: **Create device**
3. Wähle: **Pixel 5** oder **Pixel 4a** (schneller)
4. System Image: **API Level 31+** (mind. Android 12)
5. **Finish**

### 2.3 Emulator starten
```bash
emulator -avd Pixel_5_API_31
```
Oder direkt in Android Studio: Device Manager → Play-Button

---

## Schritt 3: VS Code Setup (10 min)

### 3.1 VS Code Extensions installieren
1. Öffne VS Code
2. **Extensions** (Ctrl+Shift+X)
3. Installiere:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)

### 3.2 VS Code konfigurieren
1. **File** → **Open Folder**
2. Wähle: `capture-app` Ordner
3. VS Code sollte automatisch erkennen: "Dart project detected"

---

## Schritt 4: Repository clonen

```bash
# PowerShell oder CMD öffnen
cd C:\Users\[DeinBenutzername]\Desktop

git clone https://github.com/heku-fahrzeugbau/capture-app.git
cd capture-app
```

---

## Schritt 5: Dependencies installieren

```bash
flutter pub get
```

Dies lädt alle Packages herunter (pubspec.yaml)

---

## Schritt 6: App starten (erstes Mal)

### 6.1 Emulator starten (falls noch nicht)
```bash
flutter emulators --launch Pixel_5_API_31
```

Warte bis Android Emulator vollständig geladen ist.

### 6.2 Flutter App starten
```bash
flutter run
```

Was du sehen solltest:
1. ✅ Kompiliert...
2. ✅ Deployed zu Emulator...
3. ✅ LoginScreen mit "Mit Google verbinden" Button
4. ✅ App lädt auf Emulator

Falls **Error:** Gehe zu **Troubleshooting** unten.

---

## Schritt 7: Google OAuth konfigurieren

### 7.1 Google Cloud Console
1. Gehe zu: https://console.cloud.google.com
2. **Neues Projekt** erstellen: "Quick Notes App"
3. Warte auf Erstellung

### 7.2 Google Drive API aktivieren
1. **APIs & Services** → **Library**
2. Suche: `Google Drive API`
3. **Enable**

### 7.3 OAuth 2.0 Credential (Android)
1. **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
2. Wähle: **Android application**
3. Gib ein:
   - **Package name:** `com.example.capture_app`
   - **SHA-1 certificate:** (siehe Schritt 7.4)

### 7.4 SHA-1 Fingerprint generieren
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Copy: **SHA1** Wert → in Google Cloud Console einfügen

### 7.5 Client ID in Code eintragen
Nicht nötig für Flutter (google_sign_in verwaltet OAuth automatisch)

---

## Schritt 8: Erste Tests

### Test 1: App starten
```bash
flutter run
```

### Test 2: Login testen
1. Klick: **Mit Google verbinden**
2. Browser sollte Google-Login öffnen
3. Melde dich an → App zeigt HomeScreen

### Test 3: Voice Recording testen
1. Text eingeben: "Test Notiz"
2. Oder Mic-Button → sprechen
3. Send-Button → Notiz sollte gespeichert werden

### Test 4: Archive öffnen
1. Unten: **Archive** Tab
2. Notiz sollte angezeigt werden mit Status "Ausstehend"

### Test 5: Sync testen
1. Settings öffnen (Hamburger Menu)
2. **Jetzt Synchronisieren**
3. Status sollte → "Synchronisierung" → "Synchronisiert" ändern
4. Google Drive prüfen: .md Datei dort?

---

## Troubleshooting

### "Flutter command not found"
**Fix:**
```bash
# Verifikation
flutter --version

# Falls immer noch nicht: Windows neu starten!
```

### "No connected devices"
**Fix:**
- Android Emulator starten: `emulator -avd Pixel_5_API_31`
- Oder: `flutter devices` (listet verfügbare)

### "Build failed"
**Fix:**
```bash
flutter clean
flutter pub get
flutter run
```

### "App crashed beim Start"
**Check:**
- VS Code Console (unten): Error-Messages lesen
- Häufig: Google OAuth nicht konfiguriert

### "Voice Recording funktioniert nicht"
**Check:**
- Emulator-Permissions: Settings → Apps → Permissions → Microphone → Allow
- Oder: Android 12+ Required

### "Google Sign-In funktioniert nicht"
**Check:**
- SHA-1 Certificate korrekt in Google Cloud Console?
- Package name: `com.example.capture_app` identisch?

---

## Entwicklung starten

### Hot Reload (während `flutter run` aktiv)
```
r     → Hot Reload (schnell, Code-Änderungen)
R     → Hot Restart (alles neuladen)
q     → Quit (App stoppen)
```

### Code ändern & testen
1. Öffne: `lib/screens/home_screen.dart`
2. Ändere: Text "Notiz bereit" zu "Notiz bereit!"
3. Speichere: Ctrl+S
4. Drücke: `r` (Hot Reload)
5. App sollte sofort aktualisiert sein ✅

---

## Performance während Entwicklung

**Tipps für schnellere Entwicklung:**

1. **Release Build nur für finale Tests**
   ```bash
   flutter run --release
   ```

2. **Debug-Modus ist Standard** (schneller)
   ```bash
   flutter run
   ```

3. **Emulator vs. echtes Handy**
   - Emulator: Langsamer, aber gut zum Entwickeln
   - Handy: Schneller, braucht USB-Debugging

---

## Handy-Deployment (später)

### USB-Debugging auf Android-Handy
1. **Settings** → **About** → Tap **Build Number** 7x
2. **Settings** → **Developer Options** → USB Debugging ON
3. Handy mit USB verbinden
4. Trust auf Handy: "Trust this computer?"

### Flutter auf Handy deployen
```bash
flutter devices     # Sollte Handy anzeigen
flutter run         # Deployed zu Handy
```

---

## Nächste Schritte

1. ✅ Flutter installieren
2. ✅ Repository klonen
3. ✅ `flutter run` starten
4. ✅ Voice Recording testen
5. ✅ Google OAuth testen
6. ✅ Sync zu Google Drive testen
7. 📝 Feedback geben

Wenn alles funktioniert → Schreib eine kurze Nachricht mit Feedback!

---

## Kontakt bei Problemen

Bei Fehlern:
1. Lese Troubleshooting oben
2. Gib mir: Fehler-Message aus VS Code Console
3. Dann fixen wir's gemeinsam

Viel Erfolg! 🚀
