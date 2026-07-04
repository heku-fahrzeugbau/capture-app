import SwiftUI

struct ArchiveView: View {
    @State private var searchText = ""
    @State private var notes: [Note] = []
    
    var body: some View {
        VStack(spacing: 12) {
            // Top Navigation
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Search Bar
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
            
            // Notes Grid
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(notes) { note in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(note.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(note.content.prefix(80) + "...")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white).opacity(0.65)
                                .lineLimit(2)
                            
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
        .background(Color(red: 0, green: 0, blue: 0))
        .ignoresSafeArea()
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM. HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ArchiveView()
}
