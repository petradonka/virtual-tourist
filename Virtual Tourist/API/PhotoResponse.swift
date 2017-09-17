//
//  PhotoResponse.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 09.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

//{"id":"36971460406","owner":"73730267@N06","secret":"176d23f630","server":"4397","farm":5,"title":"Presiden donator gudmor","ispublic":1,"isfriend":0,"isfamily":0,"url_z":"https:\/\/farm5.staticflickr.com\/4397\/36971460406_176d23f630_z.jpg","height_z":"640","width_z":"640"}

import Foundation

class PhotoResult {

    let id: String
    let url: String

    init(fromJSON json: [String: Any]) throws {
        guard let id = json["id"] as? String else {
            throw FlickrError.apiError(message: "Photo response is missing property: id")
        }

        guard let url = json["url_z"] as? String else {
            throw FlickrError.apiError(message: "Photo response is missing property: url_z")
        }

        self.id = id
        self.url = url
    }
}
