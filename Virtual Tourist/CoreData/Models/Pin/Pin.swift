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
}
