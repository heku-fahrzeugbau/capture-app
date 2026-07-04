import Foundation

struct MarkdownGenerator {
    static func generate(from note: Note) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
        let timeString = timeFormatter.string(from: note.timestamp)
        
        let markdown = """
        # \(note.title)
        
        **Zeitstempel:** \(timeString) Uhr
        
        \(note.content)
        
        ---
        *Erstellt mit Quick Notes App*
        """
        
        return markdown
    }
    
    static func filename(timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timeString = formatter.string(from: timestamp)
        return "notiz_\(timeString).md"
    }
    
    static func extractTitle(from content: String) -> String {
        let lines = content.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
        let firstLine = String(lines.first ?? "").trimmingCharacters(in: .whitespaces)
        
        if firstLine.isEmpty {
            return "Notiz"
        }
        
        if firstLine.count > 50 {
            return String(firstLine.prefix(47)) + "..."
        }
        
        return firstLine
    }
}
