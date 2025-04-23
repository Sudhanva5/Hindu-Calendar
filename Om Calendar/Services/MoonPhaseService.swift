import Foundation
import SwiftUI

class MoonPhaseService {
    // In-memory cache
    private static var imageCache = [String: UIImage]()
    
    static func getMoonPhase(for date: Date = Date(), tithi: Tithi? = nil) async -> UIImage? {
        // If tithi is provided, use it for moon phase calculation
        let phase: Int
        if let tithi = tithi {
            phase = getMoonPhaseIndex(from: tithi)
        } else {
            // Fallback to date-based calculation if no tithi provided
            phase = calculateMoonPhase(for: date)
        }
        
        // Check cache first
        let cacheKey = "moon_phase_\(phase)"
        if let cachedImage = imageCache[cacheKey] {
            return cachedImage
        }
        
        // Add artificial delay to show loading state
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds delay
        
        // Load from assets
        let imageName = "moon-phase-\(phase)"
        if let image = UIImage(named: imageName) {
            // Cache the image
            imageCache[cacheKey] = image
            return image
        }
        
        return nil
    }
    
    // Calculate moon phase (0-29) based on tithi
    private static func getMoonPhaseIndex(from tithi: Tithi) -> Int {
        // Convert tithi number to moon phase index (0-29)
        // Shukla Paksha (Waxing): New Moon (0) to Full Moon (15)
        // Krishna Paksha (Waning): Full Moon (15) to New Moon (29/0)
        if tithi.paksha == "Shukla" {
            // Shukla paksha (Waxing): tithi 1-15 maps to phases 0-15
            return tithi.number - 1
        } else {
            // Krishna paksha (Waning): tithi 1-15 maps to phases 15-29
            // We need to reverse the progression (15 -> 29, 1 -> 15)
            return 29 - (tithi.number - 1)
        }
    }
    
    // Fallback calculation based on date
    private static func calculateMoonPhase(for date: Date) -> Int {
        // Moon cycle is approximately 29.53 days
        let lunarCycle = 29.53
        
        // Reference new moon date (known new moon)
        let calendar = Calendar.current
        let referenceComponents = DateComponents(year: 2000, month: 1, day: 6)
        guard let referenceNewMoon = calendar.date(from: referenceComponents) else {
            return 0
        }
        
        // Calculate days since reference new moon
        let daysSinceReference = date.timeIntervalSince(referenceNewMoon) / (24 * 3600)
        
        // Calculate current phase (0-29)
        let phase = Int((daysSinceReference.truncatingRemainder(dividingBy: lunarCycle)).rounded()) % 30
        
        return phase
    }
    
    // Get a small moon phase icon for calendar
    static func getMoonPhaseIcon(for date: Date, tithi: Tithi? = nil) async -> UIImage? {
        return await getMoonPhase(for: date, tithi: tithi)
    }
    
    // Clear cache
    static func clearCache() {
        imageCache.removeAll()
    }
}

// SwiftUI Image extension for moon phase
extension Image {
    static func moonPhase(for date: Date) -> Image {
        // Default to system moon icon
        Image(systemName: "moon.circle")
    }
}

// Moon Phase View with loading state and animations
struct MoonPhaseView: View {
    let date: Date
    @State private var moonImage: UIImage?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var opacity = 0.0
    @EnvironmentObject var viewModel: PanchangaViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                // Skeleton loader for Panchanga loading
                Circle()
                    .frame(width: 200, height: 200)
                    .shimmer()
                    .transition(.opacity)
            } else {
                Group {
                    if let image = moonImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .blur(radius: 0.3)  // Very subtle blur
                            .shadow(color: .white.opacity(0.08), radius: 8)  // Inner glow
                            .shadow(color: .white.opacity(0.05), radius: 15) // Outer glow
                            .opacity(opacity)
                            .onChange(of: date) { _ in
                                withAnimation(.easeOut(duration: 0.3)) {
                                    opacity = 0.0
                                }
                            }
                    } else if isLoading {
                        // Skeleton loader for moon phase loading
                        Circle()
                            .frame(width: 200, height: 200)
                            .shimmer()
                            .transition(.opacity)
                    } else if hasError {
                        VStack {
                            Image(systemName: "moon.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .opacity(0.7)
                                .frame(width: 200, height: 200)
                            Text("Failed to load moon phase")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 8)
                        }
                        .transition(.opacity)
                    }
                }
            }
        }
        .frame(width: 250, height: 250)
        .onChange(of: viewModel.panchanga) { _ in
            Task {
                guard !viewModel.isLoading else { return }
                isLoading = true
                moonImage = await MoonPhaseService.getMoonPhase(for: date, tithi: viewModel.panchanga?.tithi)
                isLoading = false
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1.0
                }
            }
        }
        .task {
            guard !viewModel.isLoading else { return }
            do {
                isLoading = true
                moonImage = await MoonPhaseService.getMoonPhase(for: date, tithi: viewModel.panchanga?.tithi)
                isLoading = false
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1.0
                }
            } catch {
                print("Failed to load moon phase: \(error.localizedDescription)")
                hasError = true
                isLoading = false
            }
        }
    }
}

// Pulsating animation modifier
struct SlightlyPulsating: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.02 : 1.0)
            .animation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// Small Moon Phase View for calendar
struct MoonPhaseIconView: View {
    let date: Date
    @State private var moonImage: UIImage?
    @State private var isLoading = true
    @EnvironmentObject var viewModel: PanchangaViewModel
    
    var body: some View {
        Group {
            if let image = moonImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            } else if isLoading {
                Circle()
                    .frame(width: 20, height: 20)
                    .shimmer()
            } else {
                Image(systemName: "moon.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .task {
            isLoading = true
            moonImage = await MoonPhaseService.getMoonPhaseIcon(for: date, tithi: viewModel.panchanga?.tithi)
            isLoading = false
        }
        .onChange(of: viewModel.panchanga) { _ in
            Task {
                isLoading = true
                moonImage = await MoonPhaseService.getMoonPhaseIcon(for: date, tithi: viewModel.panchanga?.tithi)
                isLoading = false
            }
        }
    }
} 
