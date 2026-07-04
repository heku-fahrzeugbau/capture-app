import SwiftUI

struct ContentView: View {
    @StateObject private var appEnvironment = AppEnvironment()
    @State private var currentTab: AppTab = .home
    
    enum AppTab {
        case home
        case archive
    }
    
    var body: some View {
        Group {
            if appEnvironment.authService.isAuthenticated {
                ZStack {
                    Group {
                        if currentTab == .home {
                            HomeView()
                                .environmentObject(appEnvironment.storageService)
                        } else {
                            ArchiveView()
                                .environmentObject(appEnvironment.storageService)
                        }
                    }
                    
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Circle()
                                .fill(currentTab == .home ? Color(red: 0, green: 0.48, blue: 1) : Color.gray)
                                .frame(width: 6, height: 6)
                            
                            Circle()
                                .fill(currentTab == .archive ? Color(red: 0, green: 0.48, blue: 1) : Color.gray)
                                .frame(width: 6, height: 6)
                        }
                        .padding(.bottom, 16)
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.width > 50 {
                                withAnimation {
                                    currentTab = .archive
                                }
                            } else if gesture.translation.width < -50 {
                                withAnimation {
                                    currentTab = .home
                                }
                            }
                        }
                )
            } else {
                LoginView()
                    .environmentObject(appEnvironment.authService)
            }
        }
    }
}

#Preview {
    ContentView()
}
