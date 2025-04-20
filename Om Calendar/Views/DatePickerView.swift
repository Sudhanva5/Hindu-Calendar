import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.1, green: 0.1, blue: 0.1)
                        .ignoresSafeArea()
                    
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, -geometry.safeAreaInsets.leading - 16)
                    .colorScheme(.dark)
                }
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.height(350)])
        .presentationBackground(Color(red: 0.1, green: 0.1, blue: 0.1))
        .interactiveDismissDisabled()
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DatePickerView(selectedDate: .constant(Date()), isPresented: .constant(true))
        .preferredColorScheme(.dark)
} 
