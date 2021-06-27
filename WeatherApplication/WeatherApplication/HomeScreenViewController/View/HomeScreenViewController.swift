//
//  HomeScreenViewController.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 26/06/21.
//

import UIKit
import CoreData

class HomeScreenViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    private var homeViewModel: HomeViewMModel?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem?.title = "Welcome to weather report !!!"
        tableView.dataSource = self
        tableView.delegate = self
        //edit feature
        self.navigationItem.rightBarButtonItem = editButtonItem
        self.homeViewModel = HomeViewMModel()
        self.homeViewModel?.fetchedResultsController?.delegate = self
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Toggles the actual editing actions appearing on a table view
        tableView.setEditing(editing, animated: true)
    }

}


extension HomeScreenViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let locations = self.homeViewModel?.fetchLocationsObject() else { return 0 }
        return locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        let location = self.homeViewModel?.locationObjectAtIndex(index: indexPath)
        
        cell?.textLabel?.text = location?.name
        cell?.detailTextLabel?.text = location?.addressDetails
        return cell ?? UITableViewCell()
    }


    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            guard let location = self.homeViewModel?.locationObjectAtIndex(index: indexPath) else { return }

            self.homeViewModel?.removeLocationFromBookmark(location)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Navigate to detail view
        guard let location = self.homeViewModel?.locationObjectAtIndex(index: indexPath) else { return }
        let viewModel = WeatherInfoViewModel(with: location)
        let detailView = WeatherInfoDetailViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(detailView, animated: true)
    }
}

extension HomeScreenViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
            
        default:
            print("...")
        }
    }
}

