//
//  Constants.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 2/24/25.
//

import Foundation

struct Constants {
    private static let baseUrlPath = "http://127.0.0.1:8080/api"
    
    struct Urls {
        static let restaurants = URL(string: "\(baseUrlPath)/restaurants")!
        static let reviews = URL(string: "\(baseUrlPath)/reviews")!
    }
}
