//
//  ViewController.swift
//  Assingment
//
//  Created by Gill Hardeep on 13/04/20.
//  Copyright © 2020 Gill Hardeep. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var city1: UILabel!
    @IBOutlet weak var city1Temp: UILabel!
    @IBOutlet weak var city1MinTemp: UILabel!
    @IBOutlet weak var city1MaxTemp: UILabel!
    @IBOutlet weak var city1Humidity: UILabel!
    @IBOutlet weak var city2Name: UILabel!
    @IBOutlet weak var city2Temp: UILabel!
    @IBOutlet weak var city2MinTemp: UILabel!
    @IBOutlet weak var city2MaxTemp: UILabel!
    @IBOutlet weak var city2Humidity: UILabel!
    @IBOutlet weak var city3Name: UILabel!
    @IBOutlet weak var city3Temp: UILabel!
    @IBOutlet weak var city3MinTemp: UILabel!
    @IBOutlet weak var city3MaxTemp: UILabel!
    @IBOutlet weak var city3Humidity: UILabel!
    
    var timer = Timer()
    
    var semaphore = DispatchSemaphore (value: 0)
    
    let date = Int(Date().timeIntervalSince1970)
    
    var coordinates: [Double]?{
        didSet{
            postLocation()
        }
    }
    
//    struct Locations: Codable{
//        let loc: [String : [Any]]
//    }
    
    let cityArr = ["bengaluru", "mumbai", "delhi"]
    
    struct WeatherData: Codable {
        let name: String
        let main: Main
    }
    struct Main: Codable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
        let humidity: Double
    }
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
        centerViewOnLocation()
        
        updateWeather()
        createPolyline()
//        fetchLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { (time) in
            self.locationManager.startUpdatingLocation()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { (time) in
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func centerViewOnLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func createPolyline(){
        guard let location = locationManager.location?.coordinate else{return}
        print(location)
        let request = createDirections()
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            guard let response = response else{
                print(error!)
                return
            }
            for route in response.routes{
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirections() -> MKDirections.Request {
        let startingPoint = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 28.614116, longitude: 77.210348))
        let destinationPoint = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 29.510133, longitude: 75.455502))
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingPoint)
        request.destination = MKMapItem(placemark: destinationPoint)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
    
    //MARK:- fetch data for cities
    
    func updateWeather() {
        for city in cityArr {
            let url = "https://api.openweathermap.org/data/2.5/weather?id=524901&APPID=fec2fe10750f06b18907eba3c724a172&units=metric&q=\(city)"
            if let urlString = URL(string: url){
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: urlString) { (data, response, error) in
                    if error != nil{
                        print(" first error \(error!)")
                        return
                    }
                    if let safeData = data {
                        do{
                            let decodedData = try JSONDecoder().decode(WeatherData.self, from: safeData)
                            //                            let name = decodedData.name
                            //                            let temp = decodedData.main.temp
                            //                            let minTemp = decodedData.main.temp_min
                            //                            let maxTemp = decodedData.main.temp_max
                            //                            let humidity = decodedData.main.humidity
                            //                            print(name, temp, minTemp, maxTemp, humidity)
                            DispatchQueue.main.async {
                                if city == "bengaluru"{
                                    self.city1.text = decodedData.name
                                    self.city1Temp.text = "\(decodedData.main.temp)"
                                    self.city1MinTemp.text = "\(decodedData.main.temp_min)"
                                    self.city1MaxTemp.text = "\(decodedData.main.temp_max)"
                                    self.city1Humidity.text = "\(decodedData.main.humidity)"
                                }else if city == "mumbai"{
                                    self.city2Name.text = decodedData.name
                                    self.city2Temp.text = "\(decodedData.main.temp)"
                                    self.city2MinTemp.text = "\(decodedData.main.temp_min)"
                                    self.city2MaxTemp.text = "\(decodedData.main.temp_max)"
                                    self.city2Humidity.text = "\(decodedData.main.humidity)"
                                }else if city == "delhi"{
                                    self.city3Name.text = decodedData.name
                                    self.city3Temp.text = "\(decodedData.main.temp)"
                                    self.city3MinTemp.text = "\(decodedData.main.temp_min)"
                                    self.city3MaxTemp.text = "\(decodedData.main.temp_max)"
                                    self.city3Humidity.text = "\(decodedData.main.humidity)"
                                }
                                
                            }
                        }catch{
                            print(error)
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    //MARK:- post data on api
    
    func postLocation() {
        
        let parameters = "{\n\t\"name\": \"test\",\n\t\"loc\": \(coordinates!),\n\t\"time\" : \(date)\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://96gw5cphgi.execute-api.ap-south-1.amazonaws.com/latest/")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            //            print(String(data: data, encoding: .utf8)!)
            self.semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        
    }
    
//    func fetchLocations(){
//        var request = URLRequest(url: URL(string: "https://96gw5cphgi.execute-api.ap-south-1.amazonaws.com/latest/test")!,timeoutInterval: Double.infinity)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        request.httpMethod = "GET"
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data else {
//                print(String(describing: error))
//                return
//            }
////            print(String(data: data, encoding: .utf8))
//            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//              // appropriate error handling
//              return
//            }
////            do{
////                let decodedLocations = try JSONDecoder().decode(Locations.self, from: data)
////                let coord = decodedLocations.loc
////                print(coord)
////            }catch{
////                print(error)
////            }
//            self.semaphore.signal()
//        }
//
//        task.resume()
//        semaphore.wait()
//    }
}
//MARK:- getting user location

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            coordinates = [lat, long]
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("this is the error \(error)")
    }
}
