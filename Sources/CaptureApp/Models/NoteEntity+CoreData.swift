import CoreData

@NSManaged public class NoteEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var timestamp: Date
    @NSManaged public var syncStatus: String
    @NSManaged public var filename: String
    @NSManaged public var googleDriveFileID: String?
    @NSManaged public var errorMessage: String?
    @NSManaged public var retryCount: Int16
}

extension NoteEntity {
    static let entityName = "NoteEntity"
    
    func toDomain() -> Note {
        Note(
            id: id,
            title: title.isEmpty ? "Notiz" : title,
            content: content,
            timestamp: timestamp,
            syncStatus: SyncStatus(rawValue: syncStatus) ?? .pending
        )
    }
}

extension Note {
    func toCoreData(context: NSManagedObjectContext) -> NoteEntity {
        let entity = NoteEntity(context: context)
        entity.id = id
        entity.title = title
        entity.content = content
        entity.timestamp = timestamp
        entity.syncStatus = syncStatus.rawValue
        entity.filename = filename
        entity.retryCount = 0
        return entity
    }
}
