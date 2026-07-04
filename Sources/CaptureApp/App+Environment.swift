import SwiftUI

// Global environment for services
class AppEnvironment: ObservableObject {
    @Published var authService = GoogleAuthService()
    @Published var driveService = GoogleDriveService()
    @Published var voiceService = VoiceService()
    @Published var storageService = OfflineStorageService()
}
