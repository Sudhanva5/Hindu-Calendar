import SwiftUI
import CoreLocation
import os
import Combine

class PanchangaViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var panchanga: Panchanga?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private let locationService = LocationService.shared
    private let logger = Logger(subsystem: "com.omcalendar", category: "Panchanga")
    private var lastCalculatedLocation: CLLocation?
    private var lastCalculatedDate: Date?
    
    // Minimum distance (in meters) required for recalculation
    private let significantDistanceThreshold: CLLocationDistance = 100000 // 100 km
    
    init() {
        setupLocationObserver()
    }
    
    private func setupLocationObserver() {
        // Observe location updates
        locationService.$location
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                guard let self = self,
                      let newLocation = location else { return }
                
                // Check if we should recalculate based on distance
                if let lastLocation = self.lastCalculatedLocation {
                    let distance = newLocation.distance(from: lastLocation)
                    if distance < self.significantDistanceThreshold {
                        self.logger.info("Location change (\(distance)m) below threshold, skipping recalculation")
                        return
                    }
                }
                
                self.logger.info("Significant location change detected: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
                Task { @MainActor in
                    await self.calculatePanchanga(for: Date())
                }
            }
            .store(in: &cancellables)
        
        // Initial calculation if location is available
        if let location = locationService.location {
            self.logger.info("Initial location available: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            Task { @MainActor in
                await calculatePanchanga(for: Date())
            }
        }
    }
    
    // MARK: - Panchanga Calculation
    @MainActor
    func calculatePanchanga(for date: Date) async {
        guard let location = locationService.location else {
            logger.info("No location available, skipping panchanga calculation")
            return
        }
        
        // Check if we need to recalculate based on date
        if let lastDate = lastCalculatedDate,
           let lastLocation = lastCalculatedLocation {
            let calendar = Calendar.current
            if calendar.isDate(date, inSameDayAs: lastDate) {
                logger.info("Same day, skipping recalculation")
                return
            }
        }
        
        logger.info("Calculating panchanga for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        isLoading = true
        errorMessage = nil // Clear any previous errors
        
        do {
            let newPanchanga = try await PanchangaService.getPanchanga(for: date, location: location)
            lastCalculatedLocation = location
            lastCalculatedDate = date
            panchanga = newPanchanga // This should trigger UI update
            logger.info("Successfully calculated panchanga")
            errorMessage = nil
        } catch {
            logger.error("Failed to calculate panchanga: \(error.localizedDescription)")
            errorMessage = "Failed to calculate panchanga: \(error.localizedDescription)"
            panchanga = nil // Clear any previous panchanga data
        }
        
        isLoading = false
    }
    
    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()
}