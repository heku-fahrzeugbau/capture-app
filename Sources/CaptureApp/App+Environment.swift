import SwiftUI

class AppEnvironment: ObservableObject {
    @Published var authService = GoogleAuthService()
    @Published var driveService = GoogleDriveService()
    @Published var voiceService = VoiceService()
    @Published var storageService = OfflineStorageService()
    @Published var syncEngine: SyncEngine?
    
    init() {
        syncEngine = SyncEngine(
            storage: storageService,
            drive: driveService,
            auth: authService
        )
    }
}
