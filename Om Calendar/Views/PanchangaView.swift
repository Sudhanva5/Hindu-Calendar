import SwiftUI

struct PanchangaView: View {
    @EnvironmentObject private var viewModel: PanchangaViewModel
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Stars effect
            StarsView()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if let panchanga = viewModel.panchanga {
                VStack(spacing: 20) {
                    // Header with Tithi and Date
                    VStack(spacing: 8) {
                        Text(panchanga.tithi.name)
                            .font(.system(size: 34, weight: .thin))
                            .foregroundColor(.white)
                        
                        Text(selectedDate.formatted(date: .long, time: .omitted))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                    
                    // Moon Image
                    Image("moon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    
                    // Sunrise Sunset Card
                    GlassmorphicCard {
                        HStack(spacing: 30) {
                            VStack(spacing: 8) {
                                Image(systemName: "sunrise.fill")
                                    .font(.title2)
                                Text("Sunrise")
                                    .font(.subheadline)
                                Text(panchanga.formattedSunrise)
                                    .font(.title3)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                            
                            VStack(spacing: 8) {
                                Image(systemName: "sunset.fill")
                                    .font(.title2)
                                Text("Sunset")
                                    .font(.subheadline)
                                Text(panchanga.formattedSunset)
                                    .font(.title3)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 30)
                    }
                    .padding(.horizontal)
                    
                    // Main Panchanga Details Card
                    GlassmorphicCard {
                        VStack(spacing: 16) {
                            PanchangaRow(title: "Samvatsara", value: panchanga.samvatsara.name)
                            PanchangaRow(title: "Ayana", value: panchanga.ayana)
                            PanchangaRow(title: "Rutu", value: panchanga.rutu.name)
                            PanchangaRow(title: "Masa", value: panchanga.masa.name)
                            PanchangaRow(title: "Tithi", value: panchanga.tithi.name)
                            PanchangaRow(title: "Solar Month", value: panchanga.solarMasa.name)
                            PanchangaRow(title: "Nakshatra", value: panchanga.nakshatra.name)
                            PanchangaRow(title: "Yoga", value: panchanga.yoga.name)
                            PanchangaRow(title: "Karana", value: panchanga.karana.name)
                        }
                        .padding(.vertical, 20)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Bottom Navigation
                    HStack(spacing: 100) {
                        Button(action: { showDatePicker = true }) {
                            GlassmorphicButton(systemImage: "calendar", text: "")
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.calculatePanchanga(for: selectedDate)
                            }
                        }) {
                            GlassmorphicButton(systemImage: "arrow.clockwise", text: "")
                        }
                    }
                    .padding(.bottom, 30)
                }
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerView(selectedDate: $selectedDate, isPresented: $showDatePicker)
        }
        .onChange(of: selectedDate) { _ in
            Task {
                await viewModel.calculatePanchanga(for: selectedDate)
            }
        }
    }
}

#Preview {
    PanchangaView()
} 