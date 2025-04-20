import SwiftUI
import UserNotifications

struct RemindersView: View {
    @Binding var isPresented: Bool
    @AppStorage("amavasya_notifications") private var amavasyaNotifications = false
    @AppStorage("ekadashi_notifications") private var ekadashiNotifications = false
    @AppStorage("purnima_notifications") private var purnimaNotifications = false
    @AppStorage("notificationTime") private var notificationTime = Date()
    @AppStorage("omChantEnabled") private var omChantEnabled = true
    @AppStorage("omChantVolume") private var omChantVolume = 0.5
    @State private var showTimePicker = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    notificationsSection
                    omChantSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                
                // Credits section at bottom
                VStack(spacing: 0) {
                    // Blue container with text
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.footnote)
                            .foregroundColor(.gray.opacity(0.9))
                        Text("Vibecoded by Sudhanva and Claude")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.gray.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.2))
                    
                    // Social links with dividers
                    HStack {
                        ForEach(SocialLink.allCases, id: \.self) { link in
                            if link != .website {
                                Divider()
                                    .frame(height: 24)
                                    .background(Color.gray.opacity(0.3))
                            }
                            Button(action: {
                                if let url = URL(string: link.url) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Image(link.imageName)
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .frame(maxWidth: .infinity)
                                    .tint(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                }
                .background(.ultraThinMaterial.opacity(0.4))
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .background(
                Color(red: 0.1, green: 0.1, blue: 0.1)
                    .ignoresSafeArea()
            )
            .sheet(isPresented: $showTimePicker) {
                NavigationView {
                    GeometryReader { geometry in
                        ZStack {
                            Color(red: 0.1, green: 0.1, blue: 0.1)
                                .ignoresSafeArea()
                            
                            DatePicker(
                                "",
                                selection: $notificationTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, -geometry.safeAreaInsets.leading - 16)
                            .colorScheme(.dark)
                        }
                    }
                    .navigationTitle("Pick Time")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showTimePicker = false
                                Task {
                                    await NotificationManager.shared.scheduleNotifications()
                                }
                            }
                        }
                    }
                }
                .presentationDetents([.height(300)])
                .presentationBackground(Color(red: 0.1, green: 0.1, blue: 0.1))
                .interactiveDismissDisabled()
                .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: omChantEnabled) { newValue in
            if newValue {
                AudioManager.shared.playOmChant()
            } else {
                AudioManager.shared.fadeOut()
            }
        }
        .onChange(of: omChantVolume) { newValue in
            AudioManager.shared.setVolume(Float(newValue))
        }
    }
    
    private var notificationsSection: some View {
        Section {
            // Amavasya notifications toggle
            Toggle(isOn: $amavasyaNotifications) {
                Text("Amavasya Notifications")
            }
            .onChange(of: amavasyaNotifications) { _ in
                Task {
                    await NotificationManager.shared.scheduleNotifications()
                }
            }
            
            // Ekadashi notifications toggle
            Toggle(isOn: $ekadashiNotifications) {
                Text("Ekadashi Notifications")
            }
            .onChange(of: ekadashiNotifications) { _ in
                Task {
                    await NotificationManager.shared.scheduleNotifications()
                }
            }
            
            // Purnima notifications toggle
            Toggle(isOn: $purnimaNotifications) {
                Text("Purnima Notifications")
            }
            .onChange(of: purnimaNotifications) { _ in
                Task {
                    await NotificationManager.shared.scheduleNotifications()
                }
            }
            
            // Time picker for notifications
            if amavasyaNotifications || ekadashiNotifications || purnimaNotifications {
                Button(action: {
                    showTimePicker = true
                }) {
                    HStack {
                        Text("Remind me at")
                        Spacer()
                        Text(notificationTime.formatted(date: .omitted, time: .shortened))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color(uiColor: .secondarySystemFill))
                            .cornerRadius(8)
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("NOTIFICATIONS")
                .textCase(.uppercase)
                .foregroundColor(.secondary)
                .font(.footnote)
                .listRowInsets(EdgeInsets())
        }
    }
    
    private var omChantSection: some View {
        Section {
            Toggle(isOn: $omChantEnabled) {
                Text("Meditation Mode")
            }
            
            if omChantEnabled {
                HStack {
                    Image(systemName: "speaker.wave.1.fill")
                        .foregroundColor(.secondary)
                    Slider(value: $omChantVolume, in: 0...1)
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text("AUDIO")
                .textCase(.uppercase)
                .foregroundColor(.secondary)
                .font(.footnote)
                .listRowInsets(EdgeInsets())
        } footer: {
            Text("Play calming Om chant in the background")
                .foregroundColor(.secondary)
                .font(.footnote)
                .listRowInsets(EdgeInsets())
        }
    }
}

// Add enum for social links
enum SocialLink: CaseIterable {
    case website
    case linkedin
    case x
    case instagram
    
    var imageName: String {
        switch self {
        case .website: return "website"
        case .linkedin: return "linkedin"
        case .x: return "x"
        case .instagram: return "instagram"
        }
    }
    
    var url: String {
        switch self {
        case .website: return "https://sudhanva.webflow.io"
        case .linkedin: return "https://www.linkedin.com/in/s-m-sudhanva-acharya"
        case .x: return "https://x.com/SudhanvaAchary"
        case .instagram: return "https://www.instagram.com/sudhanva.design"
        }
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        RemindersView(isPresented: .constant(true))
    }
} 
