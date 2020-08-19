//
//  ViewController.swift
//  Test
//
//  Created by SitaRam on 18/08/20.
//  Copyright © 2020 Ojas. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var endLocation: UITextField!
    @IBOutlet weak var location: UIView!

    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0


    override func viewDidLoad() {
        super.viewDidLoad()
        showMap()
    }
    func showMap() {
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation?.coordinate.latitude ?? 17.4021395,
                                              longitude: currentLocation?.coordinate.longitude ?? 78.3727181,
                                              zoom: zoomLevel)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.isHidden = true
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        self.mapView.bringSubviewToFront(location)
        self.location.bringSubviewToFront(startLocation)
        self.location.bringSubviewToFront(endLocation)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func addAction(_ sender: Any) {
    }

    @IBAction func startAction(_ sender: Any) {

    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }

}
// Delegates to handle events for the location manager.
extension ViewController: CLLocationManagerDelegate {

  // Handle incoming location events.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location: CLLocation = locations.last!
    print("Location: \(location)")

    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude,
                                          zoom: zoomLevel)

    if mapView.isHidden {
      mapView.isHidden = false
      mapView.camera = camera
    } else {
      mapView.animate(to: camera)
    }

    //listLikelyPlaces()
  }

  // Handle authorization for the location manager.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .restricted:
      print("Location access was restricted.")
    case .denied:
      print("User denied access to location.")
      // Display the map using the default location.
      mapView.isHidden = false
    case .notDetermined:
      print("Location status not determined.")
    case .authorizedAlways: fallthrough
    case .authorizedWhenInUse:
      print("Location status is OK.")
    @unknown default:
      fatalError()
    }
  }

  // Handle location manager errors.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    print("Error: \(error)")
  }
}
