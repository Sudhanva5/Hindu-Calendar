import SwiftUI

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

#Preview {
    CalendarView()
} 