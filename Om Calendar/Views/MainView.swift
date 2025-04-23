import SwiftUI
import CoreLocation
import os

struct MainView: View {
    @StateObject private var locationService = LocationService.shared
    @EnvironmentObject private var viewModel: PanchangaViewModel
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var showSettings = false
    
    private let logger = Logger(subsystem: "com.omcalendar", category: "MainView")
    private let defaultLocation = CLLocation(latitude: 12.9716, longitude: 77.5946) // Bengaluru coordinates
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundView()
            
            VStack(spacing: 0) {
                ScrollableContent(
                    locationService: locationService,
                    selectedDate: $selectedDate,
                    showDatePicker: $showDatePicker,
                    showSettings: $showSettings
                )
                
                BottomNavigation(
                    showDatePicker: $showDatePicker,
                    showSettings: $showSettings
                )
            }
            
            // Error message overlay
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerView(selectedDate: $selectedDate, isPresented: $showDatePicker)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSettings) {
            RemindersView(isPresented: $showSettings)
                .presentationDetents([.height(700)])
        }
        .onChange(of: selectedDate) { newDate in
            logger.info("Date changed to: \(newDate)")
            Task { @MainActor in
                await viewModel.calculatePanchanga(for: newDate)
            }
        }
        .task {
            // Wait for location service to be ready or use default location
            if locationService.authorizationStatus == .denied {
                logger.info("Location access denied, using default location (Bengaluru)")
                locationService.location = defaultLocation
            } else {
                while locationService.location == nil {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                }
            }
            logger.info("Location ready, calculating initial panchanga")
            await viewModel.calculatePanchanga(for: selectedDate)
        }
    }
}

// Main content view to reduce complexity
private struct MainContentView: View {
    @EnvironmentObject private var viewModel: PanchangaViewModel
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    @Binding var showSettings: Bool
    let logger: Logger
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundView()
            
            VStack(spacing: 0) {
                ScrollableContent(
                    locationService: LocationService.shared,
                    selectedDate: $selectedDate,
                    showDatePicker: $showDatePicker,
                    showSettings: $showSettings
                )
                
                BottomNavigation(
                    showDatePicker: $showDatePicker,
                    showSettings: $showSettings
                )
            }
            
            // Error message overlay
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerView(selectedDate: $selectedDate, isPresented: $showDatePicker)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSettings) {
            RemindersView(isPresented: $showSettings)
                .presentationDetents([.height(700)])
        }
        .onChange(of: selectedDate) { _ in
            logger.info("Date changed to: \(selectedDate)")
            Task {
                await viewModel.calculatePanchanga(for: selectedDate)
            }
        }
        .task {
            logger.info("MainView appeared")
            await viewModel.calculatePanchanga(for: selectedDate)
        }
    }
}

// Background view component
private struct BackgroundView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            CosmicBackgroundView()
                .ignoresSafeArea()
                .opacity(0.44)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .white, location: 0),
                            .init(color: .white, location: 0.3),
                            .init(color: .clear, location: 0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
}

// Scrollable content component
private struct ScrollableContent: View {
    @ObservedObject var locationService: LocationService
    @EnvironmentObject private var viewModel: PanchangaViewModel
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    @Binding var showSettings: Bool
    @State private var headerOpacity = 0.0
    @State private var moonPhaseOpacity = 0.0
    @State private var contentOpacity = 0.0
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if locationService.authorizationStatus == .denied {
                    LocationDeniedBanner()
                        .transition(.opacity)
                }
                
                DateHeaderButton(
                    selectedDate: selectedDate,
                    panchanga: viewModel.panchanga,
                    action: { showDatePicker = true }
                )
                .padding(.top, 20)
                .opacity(headerOpacity)
                
                MoonPhaseView(date: selectedDate)
                    .padding(.vertical, 10)
                    .opacity(moonPhaseOpacity)
                
                PanchangaContent(
                    viewModel: viewModel,
                    selectedDate: selectedDate
                )
                .opacity(contentOpacity)
            }
            .padding(.horizontal)
            .padding(.bottom, 60)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2).delay(0.3)) {
                    headerOpacity = 1.0
                }
                withAnimation(.easeIn(duration: 1.2).delay(1.5)) {
                    moonPhaseOpacity = 1.0
                }
                withAnimation(.easeIn(duration: 1.2).delay(1.7)) {
                    contentOpacity = 1.0
                }
            }
            .onChange(of: selectedDate) { _ in
                headerOpacity = 0.0
                moonPhaseOpacity = 0.0
                contentOpacity = 0.0
                
                withAnimation(.easeIn(duration: 1.2).delay(0.3)) {
                    headerOpacity = 1.0
                }
                withAnimation(.easeIn(duration: 1.2).delay(1.5)) {
                    moonPhaseOpacity = 1.0
                }
                withAnimation(.easeIn(duration: 1.2).delay(1.7)) {
                    contentOpacity = 1.0
                }
            }
        }
    }
}

// Location denied banner component
private struct LocationDeniedBanner: View {
    var body: some View {
        Text("Currently using Bengaluru as default location.\nFor accurate data, please enable location access.")
            .font(.system(size: 12))
            .italic()
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.black.opacity(0.35))
            .cornerRadius(10)
            .padding()
    }
}

// Panchanga content component
private struct PanchangaContent: View {
    @ObservedObject var viewModel: PanchangaViewModel
    let selectedDate: Date
    @State private var opacity = 0.0
    @State private var contentOpacity = 0.0
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
                    .transition(.opacity)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage)
                    .transition(.opacity)
            } else if let panchanga = viewModel.panchanga {
                PanchangaDetailsContent(
                    panchanga: panchanga,
                    selectedDate: selectedDate
                )
                .opacity(contentOpacity)
            } else {
                EmptyStateView()
                    .transition(.opacity)
            }
        }
        .opacity(opacity)
        .onChange(of: viewModel.isLoading) { isLoading in
            if isLoading {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                    contentOpacity = 0
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        opacity = 1
                    }
                    withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
                        contentOpacity = 1
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 1
                }
                withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
                    contentOpacity = 1
                }
            }
        }
    }
}

// Bottom navigation component
private struct BottomNavigation: View {
    @Binding var showDatePicker: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            Button(action: { showDatePicker = true }) {
                Image(systemName: "calendar")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.leading, 30)
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gear")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.trailing, 30)
        }
        .frame(height: 50)
        .background(Color.black.opacity(0.45))
        .background(.ultraThinMaterial)
    }
}

// Date Header Button Component
private struct DateHeaderButton: View {
    let selectedDate: Date
    let panchanga: Panchanga?
    let action: () -> Void
    @State private var opacity = 0.0
    @EnvironmentObject private var viewModel: PanchangaViewModel
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if let panchanga = panchanga {
                    Text(panchanga.tithi.name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .transition(.opacity)
                    
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .transition(.opacity)
                } else {
                    Text(formattedDate)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .transition(.opacity)
                }
            }
            .opacity(opacity)
        }
        .onChange(of: viewModel.isLoading) { isLoading in
            if isLoading {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
            } else {
                // Wait for data to be fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeIn(duration: 0.8)) {
                        opacity = 1
                    }
                }
            }
        }
        .onAppear {
            // Initial appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: selectedDate)
    }
}

// Panchanga Details Content Component
private struct PanchangaDetailsContent: View {
    let panchanga: Panchanga
    let selectedDate: Date
    @EnvironmentObject var viewModel: PanchangaViewModel
    @State private var rowOpacities: [Double]
    @State private var containerOpacity = 0.0
    
    init(panchanga: Panchanga, selectedDate: Date) {
        self.panchanga = panchanga
        self.selectedDate = selectedDate
        _rowOpacities = State(initialValue: Array(repeating: 0.0, count: 10))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            PanchangaRowView(
                title: "Samvatsara",
                value: panchanga.samvatsara.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[0])
            
            PanchangaRowView(
                title: "Ayana",
                value: panchanga.ayana,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[1])
            
            PanchangaRowView(
                title: "Rithu",
                value: getRithu(from: panchanga.masa.number),
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[2])
            
            PanchangaRowView(
                title: "Masa",
                value: getMasaDisplay(from: panchanga.masa),
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[3])
            
            PanchangaRowView(
                title: "Tithi",
                value: panchanga.tithi.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[4])
            
            PanchangaRowView(
                title: "Day",
                value: getDayName(from: selectedDate),
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[5])
            
            PanchangaRowView(
                title: "Nakshatra",
                value: panchanga.nakshatra.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[6])
            
            PanchangaRowView(
                title: "Yoga",
                value: panchanga.yoga.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[7])
            
            PanchangaRowView(
                title: "Karana",
                value: panchanga.karana.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[8])
            
            SunTimesView(
                sunrise: panchanga.sunrise,
                sunset: panchanga.sunset,
                isLoading: viewModel.isLoading
            )
            .opacity(rowOpacities[9])
        }
        .background(Color.black.opacity(0.35))
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .opacity(containerOpacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                withAnimation(.easeIn(duration: 0.5)) {
                    containerOpacity = 1
                }
                animateRows()
            }
        }
        .onChange(of: panchanga) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                containerOpacity = 0
                for i in 0..<rowOpacities.count {
                    rowOpacities[i] = 0.0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeIn(duration: 0.5)) {
                    containerOpacity = 1
                }
                animateRows()
            }
        }
    }
    
    private func animateRows() {
        // Slower row animations with longer delays
        for i in 0..<rowOpacities.count {
            withAnimation(.easeIn(duration: 1.0).delay(Double(i) * 0.12 + 0.3)) {
                rowOpacities[i] = 1.0
            }
        }
    }
    
    private func getRithu(from masaNumber: Int) -> String {
        let rithus = [
            "Vasanta", "Grishma", "Varsha",
            "Sharad", "Hemanta", "Shishira"
        ]
        let index = (masaNumber - 1) / 2
        return rithus[safe: index] ?? "Unknown"
    }
    
    private func getMasaDisplay(from masa: Masa) -> String {
        if masa.isAdhika {
            return "Adhika \(masa.name)"
        }
        return masa.name
    }
    
    private func getDayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

// Extension to safely access array elements
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    MainView()
} 
