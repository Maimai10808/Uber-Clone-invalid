//
//  LocationManager.swift
//  Uber_Clone
//
//  Created by mac on 3/29/25.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManger = CLLocationManager()
    
    override init() {
        super.init()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
    }
}



extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        locationManger.startUpdatingLocation()
    }
}
