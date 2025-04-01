//
//  RideType.swift
//  Uber_Clone
//
//  Created by mac on 3/31/25.
//

enum RideType: Int, CaseIterable, Identifiable {  // Conform to Identifiable
    case uberX
    case uberBlack
    case uberXL
    case uberPool
    
    var id: String {  // Unique identifier for each RideType
        return self.rawValue.description  // You can use `rawValue` or any other unique identifier here
    }
    
    var title: String {
        switch self {
        case .uberX: return "UberX"
        case .uberBlack: return "UberBlack"
        case .uberXL: return "UberXL"
        case .uberPool: return "UberPool"
        }
    }
    
    var description: String {
        switch self {
        case .uberX: return "经济型"
        case .uberBlack: return "豪华型"
        case .uberXL: return "大型车"
        case .uberPool: return "拼车"
        }
    }
    
    var imageName: String {
        switch self {
        case .uberX: return "UberX"
        case .uberBlack: return "UberBlack"
        case .uberXL: return "UberXL"
        case .uberPool: return "UberPool"
        }
    }
    
    var baseFare: Double {
        switch self {
        case .uberX: return 5
        case .uberBlack: return 20
        case .uberXL: return 10
        case .uberPool: return 0 // Assuming uberPool has no base fare
        }
    }
    
    func computePrice(for distanceInMeters: Double) -> Double {
        let distanceInMiles = distanceInMeters / 1609.34  // Correct conversion from meters to miles
        
        switch self {
        case .uberX: return distanceInMiles * 1.5 + baseFare
        case .uberBlack: return distanceInMiles * 2.0 + baseFare
        case .uberXL: return distanceInMiles * 1.75 + baseFare
        case .uberPool: return 0 // Assuming uberPool has no price calculation
        }
    }
}
