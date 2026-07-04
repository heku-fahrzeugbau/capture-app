import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Quick Notes App")
                .font(.largeTitle)
                .bold()
            
            Text("Coming soon...")
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
