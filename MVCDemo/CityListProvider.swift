//
//  CityListProvider.swift
//  MVCDemo
//
//  Created by Manu Singh on 24/11/19.
//  Copyright © 2019 hackp93. All rights reserved.
//

import Foundation

protocol CityListFetcher {
    func getCities(completion : ([City])->Void)
}

class LocalCityFether : CityListFetcher {
    func getCities(completion: ([City]) -> Void) {
        let cityList = [City(name: "Delhi"),City(name: "Jaipur"),City(name: "Jodhpur"),City(name: "Patliputra"),City(name: "Varanasi")]
        completion(cityList)
    }
}
