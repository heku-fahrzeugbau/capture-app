import CoreData
import Combine

class OfflineStorageService: ObservableObject {
    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext
    
    @Published var notes: [Note] = []
    @Published var pendingNotes: [Note] = []
    @Published var error: String?
    
    init() {
        persistentContainer = NSPersistentContainer(name: "CaptureApp")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("❌ Core Data Error: \(error)")
            }
        }
        context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        fetchNotes()
    }
    
    func saveNote(_ note: Note) {
        let entity = note.toCoreData(context: context)
        
        do {
            try context.save()
            DispatchQueue.main.async {
                self.notes.append(note)
                if note.syncStatus == .pending {
                    self.pendingNotes.append(note)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Fehler beim Speichern: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchNotes() {
        let request = NSFetchRequest<NoteEntity>(entityName: NoteEntity.entityName)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NoteEntity.timestamp, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            DispatchQueue.main.async {
                self.notes = entities.map { $0.toDomain() }
                self.pendingNotes = self.notes.filter { $0.syncStatus == .pending }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Fehler beim Abrufen: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteNote(_ noteID: UUID) {
        let request = NSFetchRequest<NoteEntity>(entityName: NoteEntity.entityName)
        request.predicate = NSPredicate(format: "id == %@", noteID as CVarArg)
        
        do {
            let results = try context.fetch(request)
            results.forEach { context.delete($0) }
            try context.save()
            DispatchQueue.main.async {
                self.notes.removeAll { $0.id == noteID }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Fehler beim Löschen: \(error.localizedDescription)"
            }
        }
    }
    
    func updateSyncStatus(_ noteID: UUID, status: Note.SyncStatus) {
        let request = NSFetchRequest<NoteEntity>(entityName: NoteEntity.entityName)
        request.predicate = NSPredicate(format: "id == %@", noteID as CVarArg)
        
        do {
            let results = try context.fetch(request)
            results.first?.syncStatus = status.rawValue
            try context.save()
            fetchNotes()
        } catch {
            DispatchQueue.main.async {
                self.error = "Fehler beim Aktualisieren: \(error.localizedDescription)"
            }
        }
    }
    
    func syncPendingNotes() async {
        for note in pendingNotes {
            updateSyncStatus(note.id, status: .syncing)
            // TODO: Upload to Google Drive
            // On success: updateSyncStatus(.synced)
            // On error: updateSyncStatus(.failed)
        }
    }
}
