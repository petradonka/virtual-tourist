//
//  PinAnnotation.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 07.09.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation: MKPointAnnotation {
    var pin: Pin

    init(withPin _pin: Pin) {
        pin = _pin
        
        super.init()

        coordinate = pin.coordinate

        // An empty title is required for the mapView:didSelect method (to show the details without showing a callout)
        title = " "
    }
}
