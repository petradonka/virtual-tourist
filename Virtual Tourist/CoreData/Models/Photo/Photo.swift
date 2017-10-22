//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 09.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import Foundation

import Foundation
import CoreData
import UIKit

@objc(Photo)
public class Photo: NSManagedObject {

    var loading = false

    var image: UIImage? {
        get {
            guard let imageData = imageData as Data? else {
                return nil
            }
            return UIImage.init(data: imageData)
        }
    }

    var imageUrl: URL? {
        get {
            guard let urlString = imageUrlString else {
                print("No imageUrlString was present for a Photo object")
                return nil
            }

            return URL(string: urlString)
        }
    }

    var needsDownload: Bool {
        get {
            return imageData == nil && !loading
        }
    }

    func downloadPhoto(completion: @escaping (Error?) -> Void) -> Void {
        guard let url = imageUrl else {
            return
        }

        if (imageData == nil) {
            loading = true
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    completion(error!)
                    return
                }

                self.imageData = data
                self.loading = false
                completion(nil)
            }.resume()
        } else if (loading) {
            completion(nil)
        } else {
            completion(nil)
        }
    }
}
