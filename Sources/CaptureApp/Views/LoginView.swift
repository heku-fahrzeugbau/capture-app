import SwiftUI

struct LoginView: View {
    @StateObject var authService = GoogleAuthService()
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Quick Notes App")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text("Schnelle Notizen. Direkt zu Google Drive.")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    authService.authenticate()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Mit Google verbinden")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0, green: 0.48, blue: 1))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                if let error = authService.errorMessage {
                    Text(error)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.red)
                        .padding(12)
                        .background(Color(red: 1, green: 0.2, blue: 0.2, opacity: 0.1))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Text("Deine Notizen werden auf deinem Google Drive gespeichert. Keine externen Server.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(Color(red: 0, green: 0, blue: 0))
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView()
}
