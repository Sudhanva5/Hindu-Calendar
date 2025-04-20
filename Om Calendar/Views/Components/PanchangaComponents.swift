import SwiftUI

// Shimmer effect modifier
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .redacted(reason: .placeholder)
            .mask(
                GeometryReader { geo in
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: phase - 0.2),
                            .init(color: .white, location: phase),
                            .init(color: .clear, location: phase + 0.2)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 3)
                    .offset(x: -geo.size.width)
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: phase
                    )
                }
            )
            .onAppear {
                phase = 1
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// Panchanga row view component
struct PanchangaRowView: View {
    let title: String
    let value: String
    var icon: (name: String, color: Color)? = nil
    var showDivider: Bool = true
    var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if isLoading {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 80, height: 16)
                        .foregroundColor(.gray.opacity(0.3))
                        .shimmer()
                } else {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    if let icon = icon {
                        Image(systemName: icon.name)
                            .foregroundColor(icon.color)
                    }
                    if isLoading {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 120, height: 20)
                            .foregroundColor(.gray.opacity(0.3))
                            .shimmer()
                    } else {
                        Text(value)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            
            if showDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)
            }
        }
    }
}

// Loading view component
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8) { _ in
                PanchangaRowView(
                    title: "",
                    value: "",
                    showDivider: true,
                    isLoading: true
                )
            }
            SunTimesView(
                sunrise: "",
                sunset: "",
                isLoading: true
            )
        }
        .background(Color.black.opacity(0.7))
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

// Error view component
struct ErrorView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .padding()
            .background(Color.black.opacity(0.7))
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top, 10)
    }
}

// Empty state view component
struct EmptyStateView: View {
    var body: some View {
        Text("Select a date to view Panchanga details")
            .foregroundColor(.white.opacity(0.7))
            .padding()
            .background(Color.black.opacity(0.7))
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top, 10)
    }
}

// Sun times view component
struct SunTimesView: View {
    let sunrise: String
    let sunset: String
    var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            PanchangaRowView(
                title: "Sunrise",
                value: formatTime(sunrise),
                icon: (name: "sunrise.fill", color: .yellow),
                showDivider: true,
                isLoading: isLoading
            )
            
            PanchangaRowView(
                title: "Sunset",
                value: formatTime(sunset),
                icon: (name: "sunset.fill", color: .orange),
                showDivider: false,
                isLoading: isLoading
            )
        }
    }
    
    private func formatTime(_ time: String) -> String {
        // Handle empty string
        guard !time.isEmpty else { return "--:-- --" }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withFractionalSeconds
        ]
        
        guard let date = isoFormatter.date(from: time) else { return time }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
}

// Navigation button component
struct NavigationButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
    }
} 