import CoreLocation
import UIKit

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    private let manager: CLLocationManager
    
    private override init() {
        manager = CLLocationManager()
        super.init()
        
        // Configure location manager with battery-efficient settings
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer  // Reduced accuracy (1km is enough for panchanga)
        manager.distanceFilter = 10000  // Only update if moved more than 10km
        manager.allowsBackgroundLocationUpdates = false  // Disable background updates
        manager.showsBackgroundLocationIndicator = false
        manager.pausesLocationUpdatesAutomatically = true
        
        // Get initial status
        authorizationStatus = manager.authorizationStatus
        
        // Request permission if not determined
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if manager.authorizationStatus == .authorizedWhenInUse || 
                  manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
        
        // Setup notifications for app state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func appMovedToBackground() {
        manager.stopUpdatingLocation()
    }
    
    @objc private func appMovedToForeground() {
        manager.requestLocation()
    }
    
    // Function to manually request a location update
    func requestLocationUpdate() {
        manager.requestLocation()  // Single update
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
} 