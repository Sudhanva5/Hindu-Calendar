import SwiftUI

struct RemindersView: View {
    var body: some View {
        List {
            Toggle("Ekadashi Reminders", isOn: .constant(true))
            Toggle("Amavasya Reminders", isOn: .constant(true))
            Toggle("Festival Reminders", isOn: .constant(true))
        }
    }
}

#Preview {
    RemindersView()
} 