//
//  HomeViewModel.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 27/06/21.
//

import Foundation
import CoreData

struct HomeViewMModel {
    
    var fetchedResultsController: NSFetchedResultsController<LocationDetail>?
    
    init() {
        self.fetchedResultsController = DatabaseManager.shared.fetchedResultsController
        try? self.fetchedResultsController?.performFetch()
    }
    
    
    func fetchLocationsObject() -> [LocationDetail] {
        return self.fetchedResultsController?.fetchedObjects ?? []
    }
    
    func locationObjectAtIndex(index: IndexPath) -> LocationDetail? {
        return fetchedResultsController?.object(at: index)
    }
    
    func removeLocationFromBookmark(_ location: LocationDetail) {
        DatabaseManager.shared.deleteLocation(location)
    }
}
