import SwiftUI
import CoreLocation

class PanchangaViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var panchanga: Panchanga?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let locationManager = CLLocationManager()
    private var defaultLocation = CLLocation(latitude: 12.9716, longitude: 77.5946) // Bangalore
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    @MainActor
    func calculatePanchanga(for date: Date) async {
        isLoading = true
        panchanga = nil
        errorMessage = nil
        
        do {
            // Use default location to avoid location errors
            panchanga = try await PanchangaService.getPanchanga(for: date, location: defaultLocation)
        } catch {
            print("Error calculating panchanga: \(error.localizedDescription)")
            errorMessage = "Failed to calculate panchanga: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            print("Location access denied")
            // Use default location
            Task {
                await calculatePanchanga(for: Date())
            }
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We're using default location, so no need to do anything here
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        // Use default location
        Task {
            await calculatePanchanga(for: Date())
        }
    }
} 