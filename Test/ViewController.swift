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

class ViewController: UIViewController,UITextFieldDelegate,GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate{


    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startLocation: UIButton!
    @IBOutlet weak var endLocation: UIButton!
    @IBOutlet weak var location: UIView!

    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var noConnectionAlert = UIAlertController()
    var Mylatitude = CLLocationDegrees()
    var Mylongitude = CLLocationDegrees()
     var dicTempForAddress = NSMutableDictionary()
    var placeName : String = ""


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
        startLocation.addTarget(self, action: #selector(ViewController.onPickUpSearchBarButton(_:)), for:.touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    @IBAction func startLocationAction(_ sender: Any) {

    }
    @IBAction func endLocationAction(_ sender: Any) {

    }
    @IBAction func addAction(_ sender: Any) {
    }

    @IBAction func startAction(_ sender: Any) {

    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }

    @objc func onPickUpSearchBarButton(_ sender : UIButton) {
        if (UserDefaults.standard.bool(forKey: "LocationNotAllowed") == true) {
            self.noConnectionAlert = UIAlertController(title: "Please turn on Location services to continue", message: "", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (UIAlertAction) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            }
            self.noConnectionAlert.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                self.dismiss(animated: true, completion: nil)
            }
            self.noConnectionAlert.addAction(cancelAction)
            self.present(self.noConnectionAlert, animated: true, completion: nil)
        } else {

            let manager = CLLocationManager()
            manager.startUpdatingLocation()
            let lat = manager.location!.coordinate.latitude
            let long = manager.location!.coordinate.longitude
            let offset = 200.0 / 1000.0;
            let latMax = lat + offset;
            let latMin = lat - offset;
            let lngOffset = offset * cos(lat * .pi / 200.0)
            //print("lngOffset \(lngOffset)")
            let lngMax = long + lngOffset;
            let lngMin = long - lngOffset;
            let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
            let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
            let bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.autocompleteBounds = bounds
            autocompleteController.delegate = self
            autocompleteController.modalPresentationStyle = .fullScreen
            self.present(autocompleteController, animated: true, completion: nil)
        }
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

                  let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 19.0)
                  mapView.camera = camera
                  mapView.settings.compassButton = true
                  mapView.settings.myLocationButton = true
                  mapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
                  self.mapView.isMyLocationEnabled = true
                  mapView.delegate = self
                  self.view.addSubview(mapView)

                  self.dismiss(animated: true, completion: nil) // dismiss after select place

                  Mylatitude = place.coordinate.latitude
                  Mylongitude = place.coordinate.longitude

                  UserDefaults.standard.set(true, forKey: "AddressSearched")
                  UserDefaults.standard.synchronize()

                  DispatchQueue.main.async {

                      self.dicTempForAddress.setObject(place.coordinate.latitude, forKey: "PickUpLatitude" as NSCopying)
                      self.dicTempForAddress.setObject(place.coordinate.longitude, forKey: "PickUpLongitude" as NSCopying)
                      UserDefaults.standard.synchronize()



                      if(place.name == nil){
                          let alertController = UIAlertController(title: "Chosen location could not be be found", message: "", preferredStyle: .alert)
                          let defaultAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                          alertController.addAction(defaultAction)
                          self.present(alertController, animated: true, completion: nil)

                      } else {

                          if (UserDefaults.standard.bool(forKey: "AddressSelectedFromSavedAddresses") == true) {
                             // self.appDelegate.detailString = ""
                              UserDefaults.standard.set("" , forKey: "pickUpLandmark")
                              UserDefaults.standard.set(false, forKey: "AddressSelectedFromSavedAddresses")
                              UserDefaults.standard.synchronize()
                          } else {
                             // self.appDelegate.detailString = self.appDelegate.detailString
                          }

                          self.dicTempForAddress.setValue(place.name, forKey: "PickUpAddressToSend")
                          self.placeName = place.name! + ","
                          let str = place.name
                          let str1 = place.formattedAddress

                          let str2 = str! + "," + str1!
                          self.dicTempForAddress.setValue(str2, forKey: "PickUpAddressForRequest")
                          UserDefaults.standard.synchronize()
                      }
                  }
       }

       func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
           
       }

       func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            self.dismiss(animated: true, completion: nil)
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
