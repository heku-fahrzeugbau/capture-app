import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let timestamp: Date
    let syncStatus: SyncStatus
    
    enum SyncStatus: String, Codable {
        case pending
        case syncing
        case synced
        case failed
    }
    
    init(id: UUID = UUID(), title: String, content: String, timestamp: Date = Date(), syncStatus: SyncStatus = .pending) {
        self.id = id
        self.title = title
        self.content = content
        self.timestamp = timestamp
        self.syncStatus = syncStatus
    }
    
    var markdownContent: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        let timeString = formatter.string(from: timestamp)
        
        return """
        # \(title)
        
        **Zeitstempel:** \(timeString) Uhr
        
        \(content)
        
        ---
        *Erstellt mit Quick Notes App*
        """
    }
    
    var filename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timeString = formatter.string(from: timestamp)
        return "notiz_\(timeString).md"
    }
}
