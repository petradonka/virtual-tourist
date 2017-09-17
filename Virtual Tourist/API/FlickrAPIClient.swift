//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 09.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import Foundation
import MapKit

enum FlickrError: Error {
    case networkError(message: String)
    case serviceNotAvailable
    case noResults
    case apiError(message: String)
    case other(message: String)
}

class FlickrAPIClient {
    public static func getPhotos(atLocation coordinates: CLLocationCoordinate2D, completion: @escaping (PhotosResultResponse?, Error?) -> Void) {
        let request = URLRequest(url: FlickrAPIClient.URLToSearchPhotos(forLocation: coordinates)!)
        print("Flickr Request URL: \(request.url?.absoluteString ?? "not a URL")")


        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil, FlickrError.networkError(message: error!.localizedDescription))
                return
            }

            do {
                let photosResultResponse = try PhotosResultResponse(fromData: data)
                completion(photosResultResponse, nil)
            } catch let error {
                completion(nil, error)
            }


            }.resume()
    }

    private static func URLToSearchPhotos(forLocation coordinates: CLLocationCoordinate2D) -> URL? {
        let baseURL = URL(string: APIConstants.BaseURL)
        var components = URLComponents.init()
        components.queryItems = []

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.format,
                                                   value: APIConstants.DefaultQueryValues.format))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.apiKey,
                                                   value: APIConstants.DefaultQueryValues.apiKey))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.noJsonCallback,
                                                   value: APIConstants.DefaultQueryValues.noJsonCallback))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.method,
                                                   value: APIConstants.DefaultQueryValues.method))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.latitude,
                                                   value: String(coordinates.latitude)))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.longitude,
                                                   value: String(coordinates.longitude)))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.radius,
                                                   value: "10"))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.radiusUnits,
                                                   value: APIConstants.DefaultQueryValues.radiusUnits))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.extras,
                                                   value: APIConstants.DefaultQueryValues.extras))


        return components.url(relativeTo: baseURL)
    }
}
