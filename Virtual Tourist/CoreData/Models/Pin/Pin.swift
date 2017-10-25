//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 07.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
public class Pin: NSManagedObject {
    var loading = false

    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    var region: MKCoordinateRegion {
        get {
            let delta = 0.01
            let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            return MKCoordinateRegion(center: coordinate, span: span)
        }
    }

    var annotation: MKPointAnnotation {
        get {
            return PinAnnotation.init(withPin: self)
        }
    }

    var hasMissingPhotos: Bool {
        get {
            guard let photos = photos else {
                return false
            }

            return photos.contains { ($0 as! Photo).imageData == nil }
        }
    }

    func downloadPhotos(inViewContext context: NSManagedObjectContext, completion: @escaping (Error?) -> Void) {
        let pinInContext = context.object(with: objectID) as! Pin

        context.perform {
            pinInContext.loading = true
            self.loading = true

            pinInContext.photos?.forEach({ photo in
                if let photo = photo as? Photo {
                    context.delete(photo)
                    print("deleted!")
                }
            })

            FlickrAPIClient.getPhotos(atLocation: pinInContext.coordinate) { (data, error) in
                guard let data  = data else {
                    pinInContext.loading = false
                    self.loading = false
                    completion(error!)
                    return
                }

                if data.photos.count < 1 {
                    try? context.save()
                    pinInContext.loading = false
                    self.loading = false
                    completion(nil)
                }

                data.photos.forEach({ photoResult in
                    let photo = Photo.init(entity: Photo.entity(), insertInto: context)
                    photo.imageUrlString = photoResult.url
                    photo.pin = pinInContext

                    photo.downloadPhoto { error in
                        guard error == nil else {
                            completion(error!)
                            return
                        }

                        print("downloaded&added photo")
                        try? context.save()

                        if !pinInContext.hasMissingPhotos {
                            pinInContext.loading = false
                            self.loading = false
                            completion(nil)
                        }
                    }
                })
            }
        }

    }

    func downloadMissingPhotos(completion: @escaping(Error?) -> Void) {
        if hasMissingPhotos {
            loading = true
            self.photos?.forEach { photo in
                guard let photo = photo as? Photo else {
                    return
                }

                if photo.needsDownload {
                    photo.downloadPhoto { error in
                        guard error == nil else {
                            self.loading = false
                            completion(error!)
                            return
                        }

                        if !self.hasMissingPhotos {
                            self.loading = false
                            completion(nil)
                        }
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
}
