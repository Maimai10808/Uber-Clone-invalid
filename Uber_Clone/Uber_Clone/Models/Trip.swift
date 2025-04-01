import Foundation

struct Trip {
    let pickupTime: String
    let dropoffTime: String
    let destinationName: String
    let fare: Double
    let rideType: RideType
    
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
} 