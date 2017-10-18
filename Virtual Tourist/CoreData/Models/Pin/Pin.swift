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

    func downloadPhotos(inViewContext viewContext: NSManagedObjectContext, completion: @escaping () -> Void) {
        loading = true
        viewContext.performAndWait {
            self.photos?.forEach({ photo in
                if let photo = photo as? Photo {
                    viewContext.delete(photo)
                }
            })
        }

        FlickrAPIClient.getPhotos(atLocation: coordinate) { (data, error) in
            self.loading = false
            if let data = data {
                data.photos.forEach({ photoResult in
                    let photo = Photo.init(entity: Photo.entity(), insertInto: viewContext)
                    photo.imageUrlString = photoResult.url
                    photo.pin = self
                    viewContext.insert(photo)
                    photo.downloadPhoto {
                        print("finished adding photo to pin")
                        if (!self.arePhotosLoading) {
                            completion()
                        }
                    }
                })
            }
        }
    }
}
