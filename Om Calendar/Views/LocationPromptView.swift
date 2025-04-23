import SwiftUI

struct LocationPromptView: View {
    let onAllowTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Enable Location")
                .font(.title)
                .bold()
            
            Text("Allow Om Calendar to use your location for accurate Panchanga calculations based on your current position.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: onAllowTapped) {
                Text("Allow Location Access")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .padding()
    }
} 