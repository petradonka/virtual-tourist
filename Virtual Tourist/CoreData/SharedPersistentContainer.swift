//
//  SharedPersistentContainer.swift
//  Virtual Tourist
//
//  Created by Petra Donka on 17.10.17.
//  Copyright © 2017 Petra Donka. All rights reserved.
//

import CoreData

class SharedPersistentContainer {

    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Virtual_Tourist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    static var viewContext: NSManagedObjectContext {
        return SharedPersistentContainer.persistentContainer.viewContext
    }

    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
