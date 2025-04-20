import SwiftUI

struct PanchangaRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("SF Pro Text", size: 16))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.custom("SF Pro Text", size: 16))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
    }
}

struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .opacity(0.7)
                    )
                    .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: 1)
            )
    }
}

struct GlassmorphicButton: View {
    let systemImage: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            if !text.isEmpty {
                Text(text)
                    .font(.custom("SF Pro Text", size: 16))
            }
        }
        .foregroundStyle(.white)
    }
}

struct StarsView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<100) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(.random(in: 0.2...0.5))
                }
            }
        }
    }
}

func getMoonPhaseIndex(from tithi: Tithi) -> Int {
    // Convert tithi number to moon phase index (0-29)
    // Amavasya (new moon) is 0, Purnima (full moon) is 14
    if tithi.paksha == "Shukla" {
        // Shukla paksha: 1-15 maps to 0-14
        return tithi.number - 1
    } else {
        // Krishna paksha: 1-15 maps to 15-29
        return tithi.number + 14
    }
} 
