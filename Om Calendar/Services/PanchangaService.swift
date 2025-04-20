import Foundation
import CoreLocation

enum PanchangaError: Error {
    case invalidURL
    case networkError(String)
    case decodingError(String)
}

class PanchangaService {
    private static let baseURL = "https://web-production-818e.up.railway.app"
    
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
            throw PanchangaError.invalidURL
        }
        
        // Configure URL session with longer timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        let session = URLSession(configuration: config)
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PanchangaError.networkError("Invalid response type")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["error"] as? String {
                    throw PanchangaError.networkError(errorMessage)
                } else {
                    throw PanchangaError.networkError("Server returned status code \(httpResponse.statusCode)")
                }
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(Panchanga.self, from: data)
            
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw PanchangaError.decodingError(decodingError.localizedDescription)
        } catch {
            print("Network error: \(error.localizedDescription)")
            throw PanchangaError.networkError(error.localizedDescription)
        }
    }
} 