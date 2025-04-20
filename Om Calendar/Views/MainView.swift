import SwiftUI
import CoreLocation

struct MainView: View {
    @StateObject private var viewModel = PanchangaViewModel()
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background with gradient mask
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
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Date Header
                    DateHeaderButton(
                        selectedDate: selectedDate,
                        panchanga: viewModel.panchanga,
                        action: { showDatePicker = true }
                    )
                    .padding(.top, 20)
                    
                    // Moon Phase
                    MoonPhaseView(date: selectedDate)
                        .environmentObject(viewModel)
                        .padding(.vertical, 10)
                    
                    // Panchanga Details
                    if viewModel.isLoading {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage)
                    } else if let panchanga = viewModel.panchanga {
                        PanchangaDetailsContent(
                            panchanga: panchanga,
                            selectedDate: selectedDate
                        )
                    } else {
                        EmptyStateView()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 60) // Padding for bottom bar
            }
            
            // Bottom Navigation (Sticky)
            HStack(spacing: 0) {
                Spacer()
                NavigationButton(icon: "calendar") { showDatePicker = true }
                Spacer()
                NavigationButton(icon: "gear") { showSettings = true }
                Spacer()
            }
            .frame(height: 44)
            .background(Color.black.opacity(0.45))
            .background(.ultraThinMaterial)
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
            Task {
                await viewModel.calculatePanchanga(for: selectedDate)
            }
        }
        .task {
            await viewModel.calculatePanchanga(for: selectedDate)
        }
        .environmentObject(viewModel)
    }
}

// Date Header Button Component
private struct DateHeaderButton: View {
    let selectedDate: Date
    let panchanga: Panchanga?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if let panchanga = panchanga {
                    Text(panchanga.tithi.name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text(formattedDate)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 10)
        }
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
    
    var body: some View {
        VStack(spacing: 0) {
            PanchangaRowView(
                title: "Samvatsara",
                value: panchanga.samvatsara.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            PanchangaRowView(
                title: "Ayana",
                value: panchanga.ayana,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            PanchangaRowView(
                title: "Rithu",
                value: getRithu(from: panchanga.masa.number),
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            PanchangaRowView(
                title: "Tithi",
                value: panchanga.tithi.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            PanchangaRowView(
                title: "Day",
                value: getDayName(from: selectedDate),
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            PanchangaRowView(
                title: "Nakshatra",
                value: panchanga.nakshatra.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            PanchangaRowView(
                title: "Yoga",
                value: panchanga.yoga.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            PanchangaRowView(
                title: "Karana",
                value: panchanga.karana.name,
                showDivider: true,
                isLoading: viewModel.isLoading
            )
            SunTimesView(
                sunrise: panchanga.sunrise,
                sunset: panchanga.sunset,
                isLoading: viewModel.isLoading
            )
        }
        .background(Color.black.opacity(0.35))
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
    
    private func getRithu(from masaNumber: Int) -> String {
        let rithus = [
            "Vasanta", "Grishma", "Varsha",
            "Sharad", "Hemanta", "Shishira"
        ]
        let index = (masaNumber - 1) / 2
        return rithus[safe: index] ?? "Unknown"
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
