import SwiftUI

struct CosmicBackgroundView: View {
    var body: some View {
        ZStack {
            Color.black
            
            // Star field effect (placeholder)
            ForEach(0..<100) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: 2, height: 2)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(Double.random(in: 0.2...0.8))
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CosmicBackgroundView()
} 