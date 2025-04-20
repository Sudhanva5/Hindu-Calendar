import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Error requesting notification authorization: \(error.localizedDescription)")
            return false
        }
    }
    
    func scheduleNotifications(for date: Date = Date()) async {
        // Clear existing notifications first
        await clearScheduledNotifications()
        
        // Get user preferences
        let amavasyaEnabled = UserDefaults.standard.bool(forKey: "amavasya_notifications")
        let ekadashiEnabled = UserDefaults.standard.bool(forKey: "ekadashi_notifications")
        let purnimaEnabled = UserDefaults.standard.bool(forKey: "purnima_notifications")
        let notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Date()
        
        // Extract hour and minute from notification time
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: notificationTime)
        let minute = calendar.component(.minute, from: notificationTime)
        
        // Schedule notifications based on preferences
        if amavasyaEnabled {
            await scheduleAmavasyaNotifications(hour: hour, minute: minute)
        }
        
        if ekadashiEnabled {
            await scheduleEkadashiNotifications(hour: hour, minute: minute)
        }
        
        if purnimaEnabled {
            await schedulePurnimaNotifications(hour: hour, minute: minute)
        }
    }
    
    private func clearScheduledNotifications() async {
        await UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func scheduleAmavasyaNotifications(hour: Int, minute: Int) async {
        // TODO: Calculate next Amavasya dates using Panchanga service
        // For now, scheduling for testing (15th of each month)
        let calendar = Calendar.current
        guard let nextDate = calendar.date(byAdding: .day, value: 15, to: Date()) else { return }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: nextDate)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = "Amavasya Today"
        content.body = "Today is Amavasya (New Moon). Check Panchanga for more details."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "amavasya",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling Amavasya notification: \(error.localizedDescription)")
        }
    }
    
    private func scheduleEkadashiNotifications(hour: Int, minute: Int) async {
        // TODO: Calculate next Ekadashi dates using Panchanga service
        // For now, scheduling for testing (11th of each month)
        let calendar = Calendar.current
        guard let nextDate = calendar.date(byAdding: .day, value: 11, to: Date()) else { return }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: nextDate)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = "Ekadashi Today"
        content.body = "Today is Ekadashi. Check Panchanga for more details."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "ekadashi",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling Ekadashi notification: \(error.localizedDescription)")
        }
    }
    
    private func schedulePurnimaNotifications(hour: Int, minute: Int) async {
        // TODO: Calculate next Purnima dates using Panchanga service
        // For now, scheduling for testing (last day of each month)
        let calendar = Calendar.current
        guard let nextDate = calendar.date(byAdding: .day, value: 30, to: Date()) else { return }
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: nextDate)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = "Purnima Today"
        content.body = "Today is Purnima (Full Moon). Check Panchanga for more details."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "purnima",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling Purnima notification: \(error.localizedDescription)")
        }
    }
} 