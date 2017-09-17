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
    var image: UIImage? {
        get {
            guard let imageData = imageData as Data? else {
                return nil
            }
            return UIImage.init(data: imageData)
        }
    }
}
