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

    var arePhotosLoading: Bool {
        get  {
            guard let photos = photos else {
                return false
            }

            return photos.reduce(false, { (areLoading, photo) -> Bool in
                guard let photo = photo as? Photo else {
                    return false
                }
                return areLoading || photo.loading
            })
        }
    }

    var needsPhotoDownloads: Bool {
        get {
            guard let photos = photos else {
                return false
            }

            return photos.reduce(false, { (needsDownload, photo) -> Bool in
                guard let photo = photo as? Photo else {
                    return false
                }
                return needsDownload || photo.needsDownload
            })
        }
    }

    func downloadPhotos(inViewContext context: NSManagedObjectContext, completion: @escaping (Error?) -> Void) {
        let pinInContext = context.object(with: self.objectID) as! Pin

        context.perform {
            pinInContext.loading = true

            pinInContext.photos?.forEach({ photo in
                if let photo = photo as? Photo {
                    context.delete(photo)
                    print("deleted!")
                }
            })
            try? context.save()

            FlickrAPIClient.getPhotos(atLocation: pinInContext.coordinate) { (data, error) in
                guard let data  = data else {
                    completion(error!)
                    return
                }

                pinInContext.loading = false
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

                        if (!pinInContext.arePhotosLoading) {
                            completion(nil)
                        }
                    }
                })
            }
        }

    }

    func downloadMissingPhotos(completion: @escaping(Error?) -> Void) {
        if needsPhotoDownloads {
            self.photos?.forEach { photo in
                guard let photo = photo as? Photo else {
                    return
                }

                if photo.needsDownload {
                    photo.downloadPhoto { error in
                        guard error == nil else {
                            completion(error!)
                            return
                        }

                        if !self.arePhotosLoading, !self.needsPhotoDownloads {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
