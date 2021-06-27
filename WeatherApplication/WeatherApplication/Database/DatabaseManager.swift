//
//  DatabaseManager.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 26/06/21.
//

import CoreData

class DatabaseManager {
    
    static let shared = DatabaseManager(containerName: "weather")

    private init(containerName: String) {
        
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<LocationDetail> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<LocationDetail> = LocationDetail.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        return fetchedResultsController
    }()
    
    
    func saveLocation(locationName: String,
                      addressDetails: String?,
                      latitude: Double?,
                      longitude: Double?) -> LocationDetail {
        let context = persistentContainer.viewContext
        let location = LocationDetail(context: context)
        location.name = locationName
        location.addressDetails = addressDetails
        location.latitude = latitude ?? 0
        location.longitude = longitude ?? 0
        location.createdAt = Date()
        saveContext()
        return location
    }
    
    func deleteLocation(_ location: LocationDetail) {
        let context = persistentContainer.viewContext
        context.delete(location)
        saveContext()
    }
    
    func fetchLocations() -> [LocationDetail] {
        let context = persistentContainer.viewContext
        do {
            return try context.fetch(LocationDetail.fetchRequest())
        } catch let e {
            debugPrint(e)
            return []
        }
    }
    
    lazy private var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "weather")
      container.loadPersistentStores { _, error in
        if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      }
      return container
    }()
    
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


