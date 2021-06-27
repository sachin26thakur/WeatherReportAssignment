//
//  UserLocationSelectionView.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 25/06/21.
//

import UIKit
import MapKit

class LocationSelectViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private var viewModel: UserLocationViewModel?
    
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
        self.viewModel = UserLocationViewModel()
        self.mapView.delegate = self
    }
    
    @IBAction private func addLocationActionHandler(_ sender: Any) {
        let coordinate = self.mapView.centerCoordinate
        
        // Add annotation:
        self.annotation = MKPointAnnotation()
        self.viewModel?.getAddress(coordinate: coordinate) { [weak self] addressTitle, details  in
            guard let self = self else { return }
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
    
    
    @IBAction private func bookMarkLocation(_ sender: Any) {
        
        if self.toggleFavButton.titleLabel?.text == "Bookmark location" {
            let title = self.annotation?.title
            let coordinate = self.annotation?.coordinate
            if let result = self.viewModel?.bookMarkLocation(coordinate: coordinate,
                                             title: title,
                                             desc: annotation?.subtitle ?? ""), result {
                self.toggleFavButton.setTitle("Remove bookmark", for: .normal)
            }
        } else {
            if let result = self.viewModel?.removeBookMarkLocation(), result {
                self.toggleFavButton.setTitle("Bookmark location", for: .normal)
            }
        }
    }
    
    
    @IBAction private func deleteLocation(_ sender: Any) {
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

