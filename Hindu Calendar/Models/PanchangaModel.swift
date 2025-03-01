import Foundation

struct Panchanga {
    let date: Date
    let tithi: Tithi
    let nakshatra: Nakshatra
    let yoga: Yoga
    let karana: Karana
    let masa: Masa
    let samvatsara: Samvatsara
}

struct Tithi {
    let number: Int
    let name: String
    let startTime: Date
    let endTime: Date
}

struct Nakshatra {
    let number: Int
    let name: String
    let startTime: Date
    let endTime: Date
}

struct Yoga {
    let number: Int
    let name: String
    let startTime: Date
    let endTime: Date
}

struct Karana {
    let number: Int
    let name: String
    let startTime: Date
    let endTime: Date
}

struct Masa {
    let number: Int
    let name: String
    let isAdhika: Bool  // For leap months
}

struct Samvatsara {
    let number: Int
    let name: String
    let cycleNumber: Int  // Which 60-year cycle
} 