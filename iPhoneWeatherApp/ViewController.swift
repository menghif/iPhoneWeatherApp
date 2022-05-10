//
//  ViewController.swift
//  Assignment3
//
//  Created by Francesco Menghi on 2021-07-19.
//

import UIKit
import Combine
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var UVIndexLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    private let apiFetch = APIFetch.getInstance()
    private var cancellables:Set<AnyCancellable> = []
    
    var locationManager:CLLocationManager!
    let geocoder = CLGeocoder()
    
    var cityName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.getCity(location:location)
            
            let zoom = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            let centerOfMap = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            // show location on the map
            self.mapView.setRegion(MKCoordinateRegion(center: centerOfMap, span: zoom), animated: true)
            self.mapView.showsUserLocation = true
        }
    }

    // reverse geocoding to get city name
    func getCity(location:CLLocation){
        self.geocoder.reverseGeocodeLocation(location) {
            (results, error) in
            if let err = error {
                print("Error when performing reverse geocoding")
                print(err)
                return
            }

            if (results != nil) {
                if (results!.count == 0) {
                    print("Sorry, couldn't find any results")
                }
                else {
                    let location:CLPlacemark = results!.first!
                    self.cityName = location.locality ?? ""
                    print("city: " + self.cityName)
                    
                    // remove accents from cityName
                    self.cityName = self.cityName.folding(options: .diacriticInsensitive, locale: .current)

                    self.updateWeather()
                }
            }
        }
    }
    
    // fetch API data using apiFetch singleton
    func updateWeather() {
        self.apiFetch.fetchData(city: self.cityName)
        self.apiFetch.$weather.receive(on: RunLoop.main).sink { (changedData) in
            self.updateLabels(data: changedData)
        }.store(in: &self.cancellables)
    }
    
    func updateLabels(data: WeatherData) {
        tempLabel.text = "\(Int(data.temp_c)) ºC"
        cityLabel.text = data.city
        windLabel.text = "\(Int(data.wind_kph)) kph  \(data.wind_dir)"
        UVIndexLabel.text = "\(Int(data.uv))"
    }
}

