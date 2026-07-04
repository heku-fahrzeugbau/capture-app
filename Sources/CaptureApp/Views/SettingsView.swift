import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var selectedTheme: String = "system"
    @State private var selectedLanguage: String = "de"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Zurück")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                .border(Color.white.opacity(0.05), width: 0.5)
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Zielordner")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text(appEnvironment.driveService.selectedFolderName ?? "Nicht gewählt")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Google-Konto")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text(appEnvironment.authService.userEmail ?? "Angemeldet")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                            Button("Abmelden") {
                                appEnvironment.authService.logout()
                            }
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .semibold))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Design")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Picker("Theme", selection: $selectedTheme) {
                                Text("System").tag("system")
                                Text("Dunkel").tag("dark")
                                Text("Hell").tag("light")
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sprache")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Picker("Language", selection: $selectedLanguage) {
                                Text("Deutsch").tag("de")
                                Text("English").tag("en")
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Version")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text("1.0.0")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(16)
                }
            }
            .background(Color(red: 0, green: 0, blue: 0))
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppEnvironment())
}
