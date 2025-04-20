import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            // Almost black background
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            
            // App Icon
            Image("LaunchIcon") // Changed to use asset name directly
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120) // Made slightly smaller for better proportion
                .clipShape(RoundedRectangle(cornerRadius: 28)) // iOS app icon corner radius
                .shadow(color: .black.opacity(0.05), radius: 20)
        }
    }
}

#Preview {
    LaunchScreen()
} 
