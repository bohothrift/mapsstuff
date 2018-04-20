//
//  ViewController.swift
//  PlymWalking
//
//  Created by Kenny Kiriga
//  Copyright © 2018 Clout Pro. All rights reserved.
//

//imports
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

protocol ModalDelegate{
    func directionsTo(searchedLatitude: CLLocationDegrees, searchedLongitude: CLLocationDegrees)
}


/*
//let place1: [String: Any] = ["location": ["lat": 43.760396, "long": -71.689744], "accuracy": 5, "name": "Bust Stop 1", "address": "17 High Sreet, Plymouth, New Hampshire, 03062, United States Of America", "types": ["bus_station"], "website": "maps.googleapis.com", "language": "en-US"]
struct Place: Codable{
    struct location: Codable {
        let lat : Double
        let long
    }
}
 */

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let didFindMyLocation = false
    var camera: GMSCameraPosition!
    var mapView: GMSMapView!
    var currentLongitude: CLLocationDegrees!
    var currentLatitude: CLLocationDegrees!
    
    var rectangle = GMSPolyline()
    
    //var snackbar: MJSnackbar!
    
    //searching button
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    //cases for JSON Error handlng. For testing and debugging purposes for the most part
    enum JSONError: String, Error {
        case NoData = "Error: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    override func viewDidLoad() {
        //get current location of device and display it
        GMSServices.provideAPIKey("AIzaSyBX8qrW5Z3nQCQIUEyNl2RbuZt0DjfdVl8")
        GMSPlacesClient.provideAPIKey("AIzaSyBX8qrW5Z3nQCQIUEyNl2RbuZt0DjfdVl8")
        
        super.viewDidLoad()
        currentLongitude = self.locationManager.location?.coordinate.longitude
        currentLatitude = self.locationManager.location?.coordinate.latitude
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 16)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        
        //Add map subview and enable location button finder along with location dot
        self.view = mapView
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true

        print(currentLatitude)
        print(currentLongitude)
        
        /*
        let circleCenter = CLLocationCoordinate2D(latitude: 43.76032937, longitude: -71.6897746)
        let circ = GMSCircle(position: circleCenter, radius: 2)
        circ.map = mapView
        
        // Create a rectangular path
        let rect = GMSMutablePath()
        rect.add(CLLocationCoordinate2D(latitude: 43.760425, longitude: -71.689756))
        rect.add(CLLocationCoordinate2D(latitude: 43.760389, longitude: -71.689772))
        rect.add(CLLocationCoordinate2D(latitude: 43.760408, longitude: -71.689688))
        rect.add(CLLocationCoordinate2D(latitude: 43.760371, longitude: -71.689707))
        
        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: rect)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
        */
        
        
        struct MarkerStruct {
            let name: String
            let lat: CLLocationDegrees
            let long: CLLocationDegrees
        }
        
        let markers = [
            MarkerStruct(name: "Bus Stop 1", lat: 43.760463, long: -71.689720),
            MarkerStruct(name: "Bus Stop 2", lat: 43.762096, long: -71.684453),
            MarkerStruct(name: "Bus Stop 3", lat: 43.758617, long: -71.682613),
            MarkerStruct(name: "Bus Stop 4", lat: 43.757714, long: -71.689846),
            MarkerStruct(name: "Memorial", lat: 43.759437, long: -71.689620),
            MarkerStruct(name: "Rounds", lat: 43.758922, long: -71.689159),
            MarkerStruct(name: "Boyd", lat: 43.758922, long: -71.689159),
            MarkerStruct(name: "Grafton Hall", lat: 43.760921, long: -71.688656),
            MarkerStruct(name: "D-Hall", lat: 43.760747, long: -71.689353),
            MarkerStruct(name: "Secret Beach", lat: 43.750977, long: -71.682448),
        ]
        
        var index : Int = 0
        for marker in markers {
            let position = CLLocationCoordinate2D(latitude: marker.lat, longitude: marker.long)
            let locationmarker = GMSMarker(position: position)
            locationmarker.title = marker.name
            locationmarker.map = mapView
            print(index)
            index += 1
        }
        
        //prepare url
        let urlString = "https://maps.googleapis.com/maps/api/place/add/json?key=AIzaSyBX8qrW5Z3nQCQIUEyNl2RbuZt0DjfdVl8"
        print(urlString)

        
        // prepare json data
        let json: [String: Any] = ["location": ["lat": 43.760463, "lng": -71.689720], "accuracy": 50, "name": "omg wtf lmao", "types": ["lodging"], "language": "en-US"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                let fuck = responseJSON["name"]
                print("adsfasdfasdfasdfkasdfkjjkfdsjkasjfdkjhklsdfljkdjlskfljakljfkdjkasdjkfjkflhsaljkfljkd")
                print(fuck)
                let truck = responseJSON["place_id"]
                print(truck)
            }
        }
        task.resume()
        
        let userAddedPlace = GMSUserAddedPlace()
        userAddedPlace.name = "titty milk baby!"
        userAddedPlace.address = "17 High Street, Plymouth, NH, 03062, United States"
        userAddedPlace.coordinate = CLLocationCoordinate2DMake(43.760463, -71.689720)
        userAddedPlace.types = ["accounting"]
        GMSPlacesClient.shared().add(userAddedPlace, callback: { (place, error) -> Void in
            if let error = error {
                print("Add Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                print("Added place with placeID \(place.placeID)")
                print("Added Place name \(place.name)")
                print("Added Place address \(place.formattedAddress)")
            }
        })
 

        /*
        let place1: [String: Any] = ["location": ["lat": 43.760396, "lng": -71.689744], "accuracy": 5, "name": "Bust Stop 1", "address": "17 High Sreet, Plymouth, New Hampshire, 03062, United States Of America", "types": ["bus_station"], "website": "maps.googleapis.com", "language": "en-US"]
        
        guard let uploadData = try? JSONEncoder().encode(place1) else {
            return
        }
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/add/json?key=AIzaSyBX8qrW5Z3nQCQIUEyNl2RbuZt0DjfdVl8")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    print ("server error")
                    return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
        }
        task.resume()
        */
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    // MARK: GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Marker tapped")
        print(marker.title)
        self.directionsTo(searchedLatitude: marker.position.latitude, searchedLongitude: marker.position.longitude)
        return false
    }
    
    func equal(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
    }
    
    //update user location at all times.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.latitude)!, zoom: 17)
        
        mapView.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
    
    //search directions and display them on UI
    func directionsTo(searchedLatitude: CLLocationDegrees, searchedLongitude: CLLocationDegrees){
        //print(searchedLatitude)
        //print(searchedLongitude)
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLatitude, longitude: currentLongitude, zoom: 13)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        let position = CLLocationCoordinate2D(latitude: searchedLatitude, longitude: searchedLongitude)
        let marker = GMSMarker(position: position)
        marker.title = "Hello World"
        marker.map = mapView
        
        //Your map initiation code
        self.view = mapView
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        let currLat = String(currentLatitude)
        let currLong = String(currentLongitude)
        
        let seLat = String(searchedLatitude)
        let seLong = String(searchedLongitude)
        
        let originCoordinateString = "\(currLat),\(currLong)"
        let destinationCoordinateString = "\(seLat),\(seLong)"
        print(currentLatitude)
        print(currentLongitude)
        print(searchedLatitude)
        print(searchedLongitude)
        
        //get api request
        let urlString = "http://maps.googleapis.com/maps/api/directions/json?origin=\(originCoordinateString)&destination=\(destinationCoordinateString)&mode=walking&sensor=false"
        
        print(urlString)
        
        //make sure URL isn't nil (spaces and stuff in the URL)
        guard let url = URL(string: urlString) else {
            print(urlString)
            print ("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            do{
                //check for nil or serialization errors
                guard let data = data else{
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }
                print(json)
                
                let arrayRoutes = json["routes"] as! NSArray
                let arrLegs = (arrayRoutes[0] as! NSDictionary).object(forKey: "legs") as! NSArray
                let arrSteps = arrLegs[0] as! NSDictionary
                
                let dicDistance = arrSteps["distance"] as! NSDictionary
                let distance = dicDistance["text"] as! String
                
                let dicDuration = arrSteps["duration"] as! NSDictionary
                let duration = dicDuration["text"] as! String
                
                print("\(distance), \(duration)")
                
                //threads for iterating through all of the points, legs, routes and steps. In this case only 1 leg (so far) and multiple steps
                DispatchQueue.global(qos: .background).async{
                    let array = json["routes"] as! NSArray
                    let dic = array[0] as! NSDictionary
                    let dic1 = dic["overview_polyline"] as! NSDictionary
                    let points = dic1["points"] as! String
                    print(points)
                    
                    DispatchQueue.main.async {
                        let path = GMSPath(fromEncodedPath: points)
                        self.rectangle.map = nil
                        self.rectangle = GMSPolyline(path: path)
                        self.rectangle.strokeWidth = 4
                        self.rectangle.strokeColor = UIColor.blue
                        self.rectangle.map = mapView
                    }
                }
            } catch let error as JSONError{
                print(error.rawValue)
            } catch let error as NSError{
                print(error.debugDescription)
            }
        })
        task.resume()
        print(self.view.frame.width/2)
        
        let button = UIButton(frame: CGRect(x: 10, y: 10, width: 100, height: 135))
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        
    }
    
    // MARK: Button Action
    @objc func pressButton(_ button: UIButton) {
        print("Button pressed 👍")
        self.viewDidLoad()
    }
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //print("Place name: \(place.name)")
        //print("Place address: \(place.formattedAddress)")
        //print("Place attributions: \(place.attributions)")
        
        //pass back long/lang to main class to do directions
        self.directionsTo(searchedLatitude: place.coordinate.latitude, searchedLongitude: place.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
