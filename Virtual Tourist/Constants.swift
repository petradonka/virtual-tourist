//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 09.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import Foundation

struct APIConstants {
    public static let BaseURL = "https://api.flickr.com/services/rest/"
    public static let APIKey = "3eba809a2c886ea6e610868124cd8103"

    struct QueryParameters {
        public static let method = "method"
        public static let apiKey = "api_key"
        public static let format = "format"
        public static let noJsonCallback = "nojsoncallback"

        public static let latitude = "lat"
        public static let longitude = "lon"
        public static let radius = "radius"
        public static let radiusUnits = "radius_units"

        public static let extras = "extras"
    }

    struct DefaultQueryValues {
        public static let method = "flickr.photos.search"
        public static let apiKey = APIConstants.APIKey
        public static let format = "json"
        public static let noJsonCallback = "1"

        public static let radiusUnits = "km"

        public static let extras = "url_z"
    }
}
