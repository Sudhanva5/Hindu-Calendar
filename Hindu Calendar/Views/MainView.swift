import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = PanchangaViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }
        }
        .preferredColorScheme(.dark) // Force dark mode for cosmic theme
        .background(CosmicBackgroundView())
    }
}

struct CalendarView: View {
    var body: some View {
        VStack {
            // Moon phase view will go here
            Text("Moon Phase")
                .font(.largeTitle)
            
            // Panchanga information
            Text("Panchanga Details")
                .font(.title)
            
            // Scrollable cards will go here
        }
    }
}

struct RemindersView: View {
    var body: some View {
        List {
            Toggle("Ekadashi Reminders", isOn: .constant(true))
            Toggle("Amavasya Reminders", isOn: .constant(true))
            Toggle("Festival Reminders", isOn: .constant(true))
        }
    }
}

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
    MainView()
} 