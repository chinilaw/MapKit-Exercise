//
//  ViewController.swift
//  MapKit Exercise
//
//  Created by Jules Lee on 31/07/2019.
//  Copyright © 2019 Jules Lee. All rights reserved.
//

import UIKit
import MapKit

class MapScreen: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocationServices()
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Check if Location Services is ON
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // setup location manager
            setupLocationManager()
            checkLocationAuthorization()
            // Then go to Info.plist to add new item Privacy Location When In Use
        } else {
            // alert user to turn them on
            
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // When app is open
            startTrackingUserLocation()
        case .denied: // When user clicked not allow
            break
        case .notDetermined: // Hadn't picked allowed or not allowed
            locationManager.requestWhenInUseAuthorization() //  We ask permission again
        case .restricted: //
            break
        case .authorizedAlways: // Also when app is in background
            break
        }
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
        
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension MapScreen: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }// if location did not change
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization() // maintenance
    }
}

extension MapScreen: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCorder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return } // makes sure there is a value
        guard center.distance(from: previousLocation) > 50 else { return } //  50 meters
        self.previousLocation = center
        
        // Error management
        geoCorder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                // Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                // Show alert informing the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
}
