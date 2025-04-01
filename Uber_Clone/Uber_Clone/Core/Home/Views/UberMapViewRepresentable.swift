//
//  UberMapViewRepresentable.swift
//  Uber_Clone
//
//  Created by mac on 3/29/25.
//

import SwiftUI
import MapKit

struct UberMapViewRepresentable: UIViewRepresentable {
    let mapView = MKMapView()
    let locationManager = LocationManager()
    @Binding var mapState: MapViewState
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    @Binding var trip: Trip?

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 如果地图处于没有输入状态，清空地图视图
        if mapState == .noInput {
            context.coordinator.clearMapView()
            DispatchQueue.main.async {
                trip = nil
            }
            return
        }
        
        // 确保选中了目标位置，才会继续更新地图
        guard let coordinate = locationViewModel.selectedLocationCoordinate else {
            print("DEBUG: No selected location coordinate")
            return
        }
        
        print("DEBUG: Map state is \(mapState)")
        print("DEBUG: Updating map with coordinate \(coordinate)")
        
        // 在地图上添加并选择目标位置标注
        context.coordinator.addAndSelectAnnotion(withCoordinate: coordinate)
        
        // 配置并显示从用户当前位置到目标位置的路径
        context.coordinator.configurePolyline(withDestinationCoordinate: coordinate)

        // 设置地图区域，确保目标位置显示在地图中央
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)  // 地图缩放级别
        )
        uiView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}



// ✅ 这里必须写上 MapCoordinator 类型定义！
extension UberMapViewRepresentable {
    class MapCoordinator: NSObject, MKMapViewDelegate {
        
        // MARK: - Properites
        let parent: UberMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        var route: MKRoute?
        var tripStartTime: Date?

        // MARK: - Lifecycle
        
        init(parent: UberMapViewRepresentable) {
            self.parent = parent
            super.init()
        }

        // MARK: - MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            self.userLocationCoordinate = userLocation.coordinate
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            self.currentRegion = region
            
            mapView.setRegion(region, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }

        func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
            print("DEBUG: Map failed to load: \(error.localizedDescription)")
        }
        
        // MARK - Helpers
        
        func addAndSelectAnnotion(withCoordinate coordinate: CLLocationCoordinate2D) {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            
            let anno = MKPointAnnotation()
            anno.coordinate = coordinate
            parent.mapView.addAnnotation(anno)
            parent.mapView.selectAnnotation(anno, animated: true)
            
            parent.mapView.showAnnotations(parent.mapView.annotations, animated: true)
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let userLocationCoordinate = self.userLocationCoordinate else {
                print("DEBUG: No user location coordinate")
                return
            }
            
            print("DEBUG: Configuring polyline from \(userLocationCoordinate) to \(coordinate)")
            
            getDestinationRoute(from: userLocationCoordinate, to: coordinate) { route in
                print("DEBUG: Got route with \(route.polyline.pointCount) points")
                
                self.route = route
                self.tripStartTime = Date()
                
                // 在主线程上更新 UI
                DispatchQueue.main.async {
                    self.parent.mapView.addOverlay(route.polyline)  // 添加路径到地图
                    let rect = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect,
                                                                   edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32))  // 设置地图边距
                    self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)  // 更新地图区域
                    
                    // 计算并显示费用
                    let distance = route.distance / 1000 // 转换为公里
                    let duration = route.expectedTravelTime / 60 // 转换为分钟
                    let fare = TripFare.calculateFare(distance: distance, waitingTime: duration, rideType: .uberX)
                    
                    // Safely unwrap `selectedLocation` and provide a default value if it's nil
                    let destinationName = self.parent.locationViewModel.selectedLocation?.title ?? "Destination"
                    
                    // 创建 Trip 对象
                    let trip = Trip(
                        pickupTime: Trip.formatTime(Date()),
                        dropoffTime: Trip.formatTime(Date().addingTimeInterval(route.expectedTravelTime)),
                        destinationName: destinationName,  // Use safely unwrapped title
                        fare: fare,
                        rideType: .uberX
                    )
                    
                    // 更新父视图的 trip 属性
                    self.parent.trip = trip
                }
            }
        }
        
        func getDestinationRoute(from userLocation: CLLocationCoordinate2D,
                                   to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> Void) {
            let userPlacemark = MKPlacemark(coordinate: userLocation)
            let destPlacemark = MKPlacemark(coordinate: destination)
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: userPlacemark)
            request.destination = MKMapItem(placemark: destPlacemark)
            let directions = MKDirections(request: request)
            
            directions.calculate { response, error in
                if let error = error {
                    print("DEBUG: Failed to get directions with error \(error.localizedDescription)")
                    return
                }
                
                guard let route = response?.routes.first else { return }
                completion(route)
            }
        }
        
        func clearMapView() {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
            
            if let currentRegion = currentRegion {
                parent.mapView.setRegion(currentRegion, animated: true)
            }
        }
    }
}
