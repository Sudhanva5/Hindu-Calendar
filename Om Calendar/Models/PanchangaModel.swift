import Foundation

struct Panchanga: Codable, Equatable {
    let tithi: Tithi
    let nakshatra: Nakshatra
    let yoga: Yoga
    let karana: Karana
    let masa: Masa
    let samvatsara: Samvatsara
    let ayana: String
    let rutu: Rutu
    let solarMasa: SolarMasa
    let sunrise: String
    let sunset: String
    
    enum CodingKeys: String, CodingKey {
        case tithi, nakshatra, yoga, karana, masa, samvatsara, ayana, rutu
        case solarMasa = "solar_masa"
        case sunrise, sunset
    }
}

struct Tithi: Codable, Equatable {
    let number: Int
    let name: String
    let paksha: String
    let startTime: String?
    let endTime: String?
    
    enum CodingKeys: String, CodingKey {
        case number, name, paksha
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

struct Nakshatra: Codable, Equatable {
    let number: Int
    let name: String
    let startTime: String?
    let endTime: String?
    
    enum CodingKeys: String, CodingKey {
        case number, name
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

struct Yoga: Codable, Equatable {
    let number: Int
    let name: String
}

struct Karana: Codable, Equatable {
    let number: Int
    let name: String
}

struct Masa: Codable, Equatable {
    let number: Int
    let name: String
    let isAdhika: Bool
    
    enum CodingKeys: String, CodingKey {
        case number, name
        case isAdhika = "is_adhika"
    }
}

struct Samvatsara: Codable, Equatable {
    let number: Int
    let name: String
}

struct Rutu: Codable, Equatable {
    let number: Int
    let name: String
}

struct SolarMasa: Codable, Equatable {
    let number: Int
    let name: String
}

// Helper functions for date formatting
extension Panchanga {
    func formattedDate(from dateString: String) -> String {
        // Handle empty string
        guard !dateString.isEmpty else { return "--:-- --" }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withFractionalSeconds
        ]
        
        guard let date = isoFormatter.date(from: dateString) else { return dateString }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
    
    var formattedSunrise: String {
        formattedDate(from: sunrise)
    }
    
    var formattedSunset: String {
        formattedDate(from: sunset)
    }
} 