//
//  APIFetch.swift
//  Assignment3
//
//  Created by Francesco Menghi on 2021-07-20.
//

import Foundation

class APIFetch:ObservableObject {
    
    let apiKey = "610ed0260e5a4d698de180225221506"
    let apiUrl = "https://api.weatherapi.com/v1/current.json"

    @Published var weather:WeatherData = WeatherData()
    
    func fetchData(city:String) {
        let originalString:String = apiUrl + "?key=" + apiKey + "&q=" + city + "&aqi=no"
        let apiEndpoint:String = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let apiURL = URL(string: apiEndpoint) else {
            print(apiEndpoint)
            print("Could not convert the string endpoint to an URL object")
            return
        }
        
        URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
            if let err = error {
                print("Error occured while fetching data from api")
                print(err)
                return
            }
            
            if let jsonData = data {
                do {
                    let decoder = JSONDecoder()
                    let decodedItem:WeatherData = try decoder.decode(WeatherData.self, from: jsonData)
                    self.weather = decodedItem
                }
                catch let error {
                    print("An error occured during JSON decoding")
                    print(error)
                }
            }
        }.resume()
    }
    
    // Singleton
    private static var shared:APIFetch?
    static func getInstance() -> APIFetch {
        if (shared != nil) {
            return shared!
        }
        else {
            shared = APIFetch()
            return shared!
        }
    }
}
