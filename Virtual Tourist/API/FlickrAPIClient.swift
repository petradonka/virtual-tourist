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
        let url = FlickrAPIClient.URLToSearchPhotos(onPage: 1, forLocation: coordinates)!
        getRandomPageNumberForQuery(withURL: url) { (pageNumber, error) in
            guard let pageNumber = pageNumber else {
                completion(nil, error!)
                return
            }

            let request = URLRequest(url: FlickrAPIClient.URLToSearchPhotos(onPage: pageNumber, forLocation: coordinates)!)
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
    }

    private static func getRandomPageNumberForQuery(withURL url: URL, completion: @escaping (Int?, Error?) -> Void) {
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil, FlickrError.networkError(message: error!.localizedDescription))
                return
            }

            do {
                let photosResultResponse = try PhotosResultResponse(fromData: data)

                // After 4000 results, all page results are the same
                // See https://stackoverflow.com/questions/1994037/flickr-api-returning-duplicate-photos and
                // https://www.flickr.com/groups/51035612836@N01/discuss/72157680701360093/
                let pageCount = min(photosResultResponse.pages, 4000 / Int(APIConstants.DefaultQueryValues.perPage)!)

                let randomPage = arc4random_uniform(UInt32(pageCount))
                completion(Int(randomPage), nil)
            } catch let error {
                completion(nil, error)
            }


            }.resume()
    }

    private static func URLToSearchPhotos(onPage page: Int, forLocation coordinates: CLLocationCoordinate2D) -> URL? {
        return URLToSearchPhotos(onPage: page, forLocation: coordinates, perPage: nil)
    }

    private static func URLToSearchPhotos(onPage page: Int, forLocation coordinates: CLLocationCoordinate2D, perPage: String?) -> URL? {
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
                                                   value: APIConstants.DefaultQueryValues.radius))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.radiusUnits,
                                                   value: APIConstants.DefaultQueryValues.radiusUnits))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.extras,
                                                   value: APIConstants.DefaultQueryValues.extras))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.perPage,
                                                   value: perPage ?? APIConstants.DefaultQueryValues.perPage))

        components.queryItems?.append(URLQueryItem(name: APIConstants.QueryParameters.page,
                                                   value: String(page)))


        return components.url(relativeTo: baseURL)
    }
}
