// ContentView.swift - Main entry point of our app
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Calendar Tab
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            // Reminders Tab
            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }
        }
        .preferredColorScheme(.dark) // Force dark mode
    }
}

// CalendarView.swift - Our main calendar screen
struct CalendarView: View {
    var body: some View {
        ZStack {
            // Cosmic Background
            CosmicBackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with location
                HStack {
                    Text("Hindu Calendar")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Moon Phase Image (from NASA)
                Image("moon_waxing_gibbous") // Placeholder - we'll make this dynamic
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                
                // Tithi Information
                Text("Shukla Navami")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Chaitra • March 9, 2025")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                // Scrollable content for details
                ScrollView {
                    VStack(spacing: 16) {
                        // Panchanga Details Section
                        PanchangaDetailsView()
                        
                        // Special Occasion Section (if any)
                        SpecialOccasionView()
                    }
                    .padding()
                }
            }
            .padding(.top, 50)
        }
    }
}

// RemindersView.swift - Our reminders screen
struct RemindersView: View {
    var body: some View {
        ZStack {
            // Same cosmic background
            CosmicBackgroundView()
                .ignoresSafeArea()
            
            VStack {
                Text("Reminder Toggles")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                // Reminder toggle list
                List {
                    ReminderToggleRow(title: "Ekadashi Reminders", description: "Notification one day before Ekadashi", isOn: true)
                    
                    ReminderToggleRow(title: "Amavasya Reminders", description: "Notification for New Moon day", isOn: false)
                    
                    ReminderToggleRow(title: "Festival Reminders", description: "Reminders for major festivals", isOn: true)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
}

// Helper Views
struct CosmicBackgroundView: View {
    var body: some View {
        // Placeholder for now - we'll enhance this with animations
        ZStack {
            Color.black
                
            // Simple gradient for cosmic effect
            RadialGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.clear]),
                center: .topLeading,
                startRadius: 100,
                endRadius: 500
            )
            
            RadialGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.clear]),
                center: .bottomTrailing,
                startRadius: 100,
                endRadius: 400
            )
        }
    }
}

struct PanchangaDetailsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Panchanga Details")
                .font(.headline)
                .padding(.bottom, 5)
            
            // Grid of details
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                DetailCard(title: "Nakshatra", value: "Rohini")
                DetailCard(title: "Yoga", value: "Shubha")
                DetailCard(title: "Karana", value: "Vishti")
                DetailCard(title: "Samvatsara", value: "Sarvari")
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
}

struct SpecialOccasionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Special Occasion")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(alignment: .leading) {
                Text("✨ Rama Navami")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Celebration of Lord Rama's birth during Shukla Paksha Navami in Chaitra month.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(red: 0.33, green: 0.18, blue: 0.4).opacity(0.4))
        .cornerRadius(15)
    }
}

struct ReminderToggleRow: View {
    let title: String
    let description: String
    @State var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 5)
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
    }
}