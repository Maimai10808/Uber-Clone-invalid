import Foundation
import MapKit
import Combine

class LocationSearchViewModel: NSObject, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var selectedLocation: MKLocalSearchCompletion?
    @Published var selectedLocationCoordinate: CLLocationCoordinate2D?
    @Published var queryFragment: String = "" {
        didSet {
            searchLocation(for: queryFragment)
        }
    }
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .query
    }
    
    func searchLocation(for query: String) {
        searchCompleter.queryFragment = query
    }
    
    func selectLocation(_ location: MKLocalSearchCompletion) {
        selectedLocation = location
        getLocationCoordinate(for: location)
    }
    
    private func getLocationCoordinate(for location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            self?.selectedLocationCoordinate = coordinate
        }
    }
}

extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("DEBUG: Location search failed with error \(error.localizedDescription)")
    }
} 
