import Foundation

struct TripFare {
    static let perKilometerRates: [RideType: Double] = [
        .uberX: 2.0,
        .uberBlack: 3.0,
        .uberXL: 2.5,
        .uberPool: 1.5
    ]
    
    static let perMinuteRates: [RideType: Double] = [
        .uberX: 0.5,
        .uberBlack: 1.0,
        .uberXL: 0.75,
        .uberPool: 0.25
    ]
    
    static let baseFares: [RideType: Double] = [
        .uberX: 5.0,
        .uberBlack: 10.0,
        .uberXL: 8.0,
        .uberPool: 3.0
    ]
    
    static func calculateFare(distance: Double, waitingTime: Double, rideType: RideType) -> Double {
        let distanceFare = distance * (perKilometerRates[rideType] ?? 0)
        let waitingFare = waitingTime * (perMinuteRates[rideType] ?? 0)
        let baseFare = baseFares[rideType] ?? 0
        
        return distanceFare + waitingFare + baseFare
    }
    
    static func formatFare(_ fare: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: fare)) ?? "$0.00"
    }
} 