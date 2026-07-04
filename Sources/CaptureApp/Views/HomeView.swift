import SwiftUI

struct HomeView: View {
    @StateObject private var voiceService = VoiceService()
    @State private var noteText = ""
    @State private var showSettings = false
    @EnvironmentObject var storageService: OfflineStorageService
    
    var isRecording: Bool {
        voiceService.isListening
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
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
                
                VStack(spacing: 8) {
                    if isRecording {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text("Aufzeichnung läuft...")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    } else if !voiceService.transcript.isEmpty {
                        Text(voiceService.transcript)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                            .lineLimit(4)
                    } else {
                        Text("Notiz bereit")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity)
                .padding(16)
                
                HStack(spacing: 8) {
                    Text("+")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.gray)
                    
                    TextField("Notiz aufzeichnen...", text: $noteText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                        .disabled(isRecording)
                    
                    Button(action: {
                        if isRecording {
                            voiceService.stopListening()
                            noteText = voiceService.transcript
                        } else {
                            voiceService.startListening()
                        }
                    }) {
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isRecording ? .red : .gray)
                    }
                    
                    Button(action: saveNote) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0, green: 0.48, blue: 1))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .disabled(noteText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color.clear)
                .border(Color(red: 0.2, green: 0.2, blue: 0.2), width: 1)
                .cornerRadius(24)
                .padding(.horizontal, 16)
                
                if let error = voiceService.error {
                    Text(error)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Online")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.green)
                    
                    if !storageService.pendingNotes.isEmpty {
                        Text("• \(storageService.pendingNotes.count) pending")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 16)
            }
            .background(Color(red: 0, green: 0, blue: 0))
            
            if showSettings {
                SettingsView()
                    .transition(.move(edge: .leading))
            }
        }
        .ignoresSafeArea()
    }
    
    private func saveNote() {
        let content = noteText.trimmingCharacters(in: .whitespaces)
        guard !content.isEmpty else { return }
        
        let title = MarkdownGenerator.extractTitle(from: content)
        let note = Note(
            title: title,
            content: content,
            timestamp: Date(),
            syncStatus: .pending
        )
        
        storageService.saveNote(note)
        noteText = ""
        voiceService.transcript = ""
    }
}

#Preview {
    HomeView()
        .environmentObject(OfflineStorageService())
}
