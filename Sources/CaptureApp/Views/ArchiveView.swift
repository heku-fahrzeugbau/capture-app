import SwiftUI

struct ArchiveView: View {
    @State private var searchText = ""
    @State private var showSettings = false
    @EnvironmentObject var storageService: OfflineStorageService
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return storageService.notes
        }
        return storageService.notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                HStack {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                    
                    TextField("Suchen...", text: $searchText)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(Color.clear)
                .border(Color(red: 0.2, green: 0.2, blue: 0.2), width: 1)
                .cornerRadius(24)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
                
                ScrollView {
                    if filteredNotes.isEmpty {
                        VStack(spacing: 8) {
                            Text("Keine Notizen")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            Text("Erstelle deine erste Notiz auf der Startseite")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray).opacity(0.6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredNotes) { note in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(note.title)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text(note.content.prefix(80).count == 80 ? 
                                                String(note.content.prefix(77)) + "..." : 
                                                String(note.content.prefix(80)))
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(.white).opacity(0.65)
                                                .lineLimit(2)
                                        }
                                        
                                        Spacer()
                                        
                                        statusBadge(note.syncStatus)
                                    }
                                    
                                    Text(dateString(note.timestamp))
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(.white).opacity(0.4)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .border(Color.white.opacity(0.1), width: 1)
                                .cornerRadius(16)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color(red: 0, green: 0, blue: 0))
            
            if showSettings {
                SettingsView()
                    .transition(.move(edge: .leading))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            storageService.fetchNotes()
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM. HH:mm"
        return formatter.string(from: date)
    }
    
    private func statusBadge(_ status: Note.SyncStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor(status))
                .frame(width: 6, height: 6)
            
            Text(statusText(status))
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(statusColor(status))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor(status).opacity(0.1))
        .cornerRadius(4)
    }
    
    private func statusColor(_ status: Note.SyncStatus) -> Color {
        switch status {
        case .pending:
            return Color.yellow
        case .syncing:
            return Color.blue
        case .synced:
            return Color.green
        case .failed:
            return Color.red
        }
    }
    
    private func statusText(_ status: Note.SyncStatus) -> String {
        switch status {
        case .pending:
            return "Ausstehend"
        case .syncing:
            return "Synchronisierung"
        case .synced:
            return "Synchronisiert"
        case .failed:
            return "Fehler"
        }
    }
}

#Preview {
    ArchiveView()
        .environmentObject(OfflineStorageService())
}
