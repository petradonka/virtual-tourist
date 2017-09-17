//
//  PhotosResult.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 13.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import Foundation

class PhotosResultResponse {

    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photos: [PhotoResult]

    init(fromData data: Data) throws {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            throw FlickrError.other(message: "Can not parse as JSON")
        }

        guard let root = json as? [String: Any],
            let stat = root["stat"] as? String,
            let photos = root["photos"] as? [String: Any] else {
                throw FlickrError.other(message: "JSON not correct")
        }

        guard stat == "ok" else {
            if let message = root["message"] as? String {
                throw FlickrError.apiError(message: message)
            }
            throw FlickrError.apiError(message: "Response is not 'OK' and there's no additional message")
        }

        guard let page = photos["page"] as? Int else {
            throw FlickrError.apiError(message: "Response is missing property: page")
        }

        guard let pages = photos["pages"] as? Int else {
            throw FlickrError.apiError(message: "Response is missing property: pages")
        }

        guard let perPage = photos["perpage"] as? Int else {
            throw FlickrError.apiError(message: "Response is missing property: perpage")
        }

        guard let totalString = photos["total"] as? String,
            let total = Int(totalString) else {
            throw FlickrError.apiError(message: "Response is missing property: total")
        }

        guard let photoArray = photos["photo"] as? [[String: Any]] else {
            throw FlickrError.apiError(message: "Response is missing property: photo")
        }

        self.page = page
        self.pages = pages
        self.perPage = perPage
        self.total = total
        self.photos = try photoArray
            .filter { $0["url_z"] != nil }
            .map { try PhotoResult.init(fromJSON: $0) }

    }
}
