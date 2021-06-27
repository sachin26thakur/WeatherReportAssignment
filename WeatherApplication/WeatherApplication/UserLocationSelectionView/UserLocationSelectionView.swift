//
//  UserLocationSelectionView.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 25/06/21.
//

import UIKit
import MapKit

class LocationSelectViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak private var mapView: MKMapView!
    private var annotation: MKPointAnnotation?
    private let regionRadius: Double = 10000
    
    @IBOutlet weak private var addLocationButton: UIButton!
    
    @IBOutlet weak private var toggleFavButton: UIButton!
    
    
    @IBOutlet weak private var removePinLocButton: UIButton!
    
    private var location: LocationDetail?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Bookmark location"
        self.mapView.delegate = self
    }
    
    @IBAction func addLocationActionHandler(_ sender: Any) {
        let coordinate = self.mapView.centerCoordinate
        
        // Add annotation:
        self.annotation = MKPointAnnotation()
        getAddress(coordinate: coordinate) { addressTitle, details  in
            self.annotation?.title = addressTitle
            self.annotation?.subtitle = details
        }
        annotation?.coordinate = coordinate
        mapView.addAnnotation(annotation!)
        self.addLocationButton.isHidden = true
        self.toggleFavButton.isHidden = false
        self.removePinLocButton.isHidden = false
        self.addLocationButton.superview?.layoutIfNeeded()
        self.addLocationButton.superview?.layoutSubviews()
        self.addLocationButton.superview?.superview?.layoutSubviews()
    }
    
    
    @IBAction func bookMarkLocation(_ sender: Any) {
        
        if self.toggleFavButton.titleLabel?.text == "Bookmark location" {
            self.toggleFavButton.setTitle("Remove bookmark", for: .normal)
            guard let title = self.annotation?.title else { return }
            let coordinate = self.annotation?.coordinate
            self.location = DatabaseManager.shared.saveLocation(locationName: title,
                                                addressDetails: self.annotation?.subtitle,
                                                latitude: coordinate?.latitude,
                                                longitude: coordinate?.longitude)
        } else {
            guard let location = self.location else { return }
            DatabaseManager.shared.deleteLocation(location)
            self.toggleFavButton.setTitle("Bookmark location", for: .normal)
        }
    }
    
    
    @IBAction func deleteLocation(_ sender: Any) {
        self.resetSetup()
    }
    
    private func resetSetup() {
        self.addLocationButton.isHidden = false
        self.removePinLocButton.isHidden = true
        self.toggleFavButton.isHidden = true
        self.removePinLocButton.setTitle("Reset", for: .normal)
        self.toggleFavButton.setTitle("Bookmark location", for: .normal)
        guard let annotation = self.annotation else {
            return
        }
        self.mapView.removeAnnotation(
            annotation)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resetSetup()
    }
    
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

}

extension LocationSelectViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.showAnnotations([userLocation], animated: true)
        
        let coordinate = userLocation.coordinate
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.largeContentTitle = "Tap to book mark this location"
            annotationView!.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let placeName = view.annotation?.title else { return }

        let ac = UIAlertController(title: placeName, message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

