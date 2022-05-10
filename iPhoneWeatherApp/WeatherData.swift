//
//  WeatherData.swift
//  Assignment3
//
//  Created by Francesco Menghi on 2021-07-20.
//

import Foundation

struct WeatherData:Codable{
    var location:String = ""
    var current = ""
    var city:String = ""
    var temp_c:Double = 0
    var wind_kph:Double = 0
    var wind_dir:String = ""
    var uv:Double = 0
    var success:Bool = false
    
    enum CodingKeys: String, CodingKey {
        case location, city = "name", current, temp_c, wind_kph, wind_dir, uv, success
    }
    
    func encode(to encoder:Encoder) throws {
        // do nothing
    }
    
    init() {
        location = ""
        current = ""
        city = ""
        temp_c = 0
        wind_kph = 0
        wind_dir = ""
        uv = 0
        success = false
    }

    init(from decoder:Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        
//        example API response in JSON:
//        {
//            "location": {
//                "name": "Montreal",
//            },
//            "current": {
//                "temp_c": 18.0,
//                "wind_kph": 20.2,
//                "wind_dir": "NW",
//                "uv": 3.0
//            }
//        }
        
        let locationResponse = try response.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
        self.city = try locationResponse.decodeIfPresent(String.self, forKey: .city) ?? "No city name given"
        
        let currentResponse = try response.nestedContainer(keyedBy: CodingKeys.self, forKey: .current)
        self.temp_c = try currentResponse.decodeIfPresent(Double.self, forKey: .temp_c) ?? 0
        self.wind_kph = try currentResponse.decodeIfPresent(Double.self, forKey: .wind_kph) ?? 0
        self.wind_dir = try currentResponse.decodeIfPresent(String.self, forKey: .wind_dir) ?? "No dir"
        self.uv = try currentResponse.decodeIfPresent(Double.self, forKey: .uv) ?? 0
        
        self.success = try response.decodeIfPresent(Bool.self, forKey: .success) ?? false
    }
}
