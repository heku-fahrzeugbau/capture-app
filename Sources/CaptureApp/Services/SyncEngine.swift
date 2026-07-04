import Foundation
import Combine
import Network

class SyncEngine: ObservableObject {
    @Published var isSyncing = false
    @Published var syncProgress: Double = 0
    @Published var lastSyncDate: Date?
    
    private let storageService: OfflineStorageService
    private let driveService: GoogleDriveService
    private let authService: GoogleAuthService
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.heku.capture.sync")
    
    private var isOnline = true
    private var syncTimer: Timer?
    
    init(
        storage: OfflineStorageService,
        drive: GoogleDriveService,
        auth: GoogleAuthService
    ) {
        self.storageService = storage
        self.driveService = drive
        self.authService = auth
        
        setupNetworkMonitoring()
        startAutoSync()
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    private func startAutoSync() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            if self?.isOnline ?? false {
                Task {
                    await self?.syncPendingNotes()
                }
            }
        }
    }
    
    func syncPendingNotes() async {
        guard !isSyncing else { return }
        guard let authToken = authService.authToken else {
            print("❌ Not authenticated")
            return
        }
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.syncProgress = 0
        }
        
        let pending = storageService.pendingNotes
        guard !pending.isEmpty else {
            DispatchQueue.main.async {
                self.isSyncing = false
                self.lastSyncDate = Date()
            }
            return
        }
        
        for (index, note) in pending.enumerated() {
            await syncNote(note, authToken: authToken, retryCount: 0)
            
            DispatchQueue.main.async {
                self.syncProgress = Double(index + 1) / Double(pending.count)
            }
        }
        
        DispatchQueue.main.async {
            self.isSyncing = false
            self.lastSyncDate = Date()
        }
    }
    
    private func syncNote(
        _ note: Note,
        authToken: String,
        retryCount: Int
    ) async {
        storageService.updateSyncStatus(note.id, status: .syncing)
        
        let markdown = MarkdownGenerator.generate(from: note)
        
        do {
            _ = try await driveService.uploadNote(note, markdown: markdown, authToken: authToken)
            storageService.updateSyncStatus(note.id, status: .synced)
            print("✅ Note synced: \(note.title)")
        } catch {
            let delay = exponentialBackoff(retryCount)
            
            if retryCount < 3 {
                try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
                await syncNote(note, authToken: authToken, retryCount: retryCount + 1)
            } else {
                storageService.updateSyncStatus(note.id, status: .failed)
                print("❌ Sync failed after retries: \(note.title)")
            }
        }
    }
    
    private func exponentialBackoff(_ retryCount: Int) -> UInt64 {
        let baseDelay: UInt64 = 2
        return baseDelay * UInt64(pow(2.0, Double(retryCount)))
    }
    
    func manualSync() {
        Task {
            await syncPendingNotes()
        }
    }
    
    deinit {
        monitor.cancel()
        syncTimer?.invalidate()
    }
}
