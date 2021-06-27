//
//  UserLocationViewModel.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 27/06/21.
//

import Foundation
import MapKit

final class UserLocationViewModel {
    
    var locationDetail: LocationDetail?
    
    // Using closure
    func getAddress(coordinate: CLLocationCoordinate2D,
                    handler: @escaping (String, String) -> Void)
    {

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarksArray, error) in
                print(placemarksArray!)
                if (error) == nil {
                    if placemarksArray!.count > 0 {
                        var addressString : String = ""
                        guard let placemark = placemarksArray?[0] else {
                            return
                        }
                        
                        if let subThoroughfare = placemark.subThoroughfare {
                            addressString = subThoroughfare + " "
                        }
             
                        if let thoroughfare = placemark.thoroughfare  {
                            addressString = addressString  + thoroughfare + ", "
                        }

                        if let postalCode = placemark.postalCode {
                            addressString = addressString + postalCode + " "
                        }
                        
                        if let locality = placemark.locality {
                            addressString = addressString + locality + ", "
                                        }
                        
                        if let administrativeArea = placemark.administrativeArea {
                            addressString = addressString + administrativeArea + " "
                                        }
                        
                        if let country = placemark.country {
                            addressString = addressString + country
                                        }
                        
                        handler(placemark.name ?? addressString, addressString)
                    }
                }

            }
    }
    
    func bookMarkLocation(coordinate: CLLocationCoordinate2D?, title: String?, desc: String?) -> Bool {
        guard let title = title, let coordinate = coordinate else {
            return false
        }
        self.locationDetail = DatabaseManager.shared.saveLocation(locationName: title,
                                            addressDetails: desc,
                                            latitude: coordinate.latitude,
                                            longitude: coordinate.longitude)
        return true
    }
    
    func removeBookMarkLocation() -> Bool {
        guard let location = self.locationDetail else { return false }
        DatabaseManager.shared.deleteLocation(location)
        return true
    }
}
