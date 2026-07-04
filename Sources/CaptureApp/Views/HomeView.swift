import SwiftUI

struct HomeView: View {
    @State private var noteText = ""
    @State private var isRecording = false
    @State private var showSettings = false
    
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
                
                VStack {
                    Text("Notiz bereit")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
                
                HStack(spacing: 8) {
                    Text("+")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.gray)
                    
                    TextField("Notiz aufzeichnen...", text: $noteText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 32, height: 32)
                            .background(Color(red: 0, green: 0.48, blue: 1))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color.clear)
                .border(Color(red: 0.2, green: 0.2, blue: 0.2), width: 1)
                .cornerRadius(24)
                .padding(.horizontal, 16)
                
                Text("Online • 0 pending")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
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
}

#Preview {
    HomeView()
}
