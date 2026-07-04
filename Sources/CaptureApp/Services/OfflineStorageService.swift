import CoreData

class OfflineStorageService: ObservableObject {
    let persistentContainer: NSPersistentContainer
    
    @Published var notes: [Note] = []
    @Published var pendingNotes: [Note] = []
    
    init() {
        persistentContainer = NSPersistentContainer(name: "CaptureApp")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data Error: \(error)")
            }
        }
    }
    
    func saveNote(_ note: Note) {
        // TODO: Save to Core Data
    }
    
    func fetchNotes() {
        // TODO: Fetch all notes from Core Data
    }
    
    func syncPendingNotes() async {
        // TODO: Upload pending notes when online
    }
}
