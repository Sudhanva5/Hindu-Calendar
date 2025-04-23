import Foundation
import CoreLocation
import os

enum PanchangaError: Error {
    case invalidURL
    case networkError(String)
    case decodingError(String)
}

class PanchangaService {
    private static let baseURL = "https://web-production-818e.up.railway.app"
    private static let logger = Logger(subsystem: "com.omcalendar", category: "PanchangaService")
    
    static func getPanchanga(for date: Date, location: CLLocation) async throws -> Panchanga {
        // Format date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        // Construct URL with parameters
        var urlComponents = URLComponents(string: "\(baseURL)/panchanga")!
        urlComponents.queryItems = [
            URLQueryItem(name: "date", value: dateString),
            URLQueryItem(name: "lat", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "lng", value: String(location.coordinate.longitude))
        ]
        
        guard let url = urlComponents.url else {
            logger.error("Failed to construct URL")
            throw PanchangaError.invalidURL
        }
        
        logger.info("Making API request to: \(url.absoluteString)")
        
        // Configure URL session with longer timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        let session = URLSession(configuration: config)
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw PanchangaError.networkError("Invalid response type")
            }
            
            logger.info("Received response with status code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["error"] as? String {
                    logger.error("Server error: \(errorMessage)")
                    throw PanchangaError.networkError(errorMessage)
                } else {
                    logger.error("Server error with status code: \(httpResponse.statusCode)")
                    throw PanchangaError.networkError("Server returned status code \(httpResponse.statusCode)")
                }
            }
            
            // Log the response data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.info("Received data: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            let panchanga = try decoder.decode(Panchanga.self, from: data)
            logger.info("Successfully decoded Panchanga data")
            return panchanga
            
        } catch let decodingError as DecodingError {
            logger.error("Decoding error: \(decodingError.localizedDescription)")
            print("Decoding error: \(decodingError)")
            throw PanchangaError.decodingError(decodingError.localizedDescription)
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            print("Network error: \(error.localizedDescription)")
            throw PanchangaError.networkError(error.localizedDescription)
        }
    }
} 