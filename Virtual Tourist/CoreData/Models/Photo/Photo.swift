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

    func downloadPhoto(completion: @escaping () -> Void) -> Void {
        if (imageData == nil) {
            loading = true
            let url = URL(string: imageUrlString!)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                self.imageData = data
                self.loading = false
                completion()
            }
        } else if (loading) {
            completion()
        } else {
            completion()
        }
    }
}
