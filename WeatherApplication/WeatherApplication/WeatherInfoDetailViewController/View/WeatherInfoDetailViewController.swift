//
//  WeatherInfoDetailViewController.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 26/06/21.
//

import UIKit

class WeatherInfoDetailViewController: UIViewController {
    
    var apiService: ApiService?
    
    var locations: [LocationDetail] = []
    
    private let viewModel: WeatherInfoViewModel
    
    private var dataModels: [[WeatherInfoModel]] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    init(viewModel: WeatherInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "WeatherInfoDetailView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem?.title = "Welcome to weather report !!!"
        tableView.dataSource = self
        
        self.viewModel.updateUIHandler = { [weak self] dataModels in
            guard let self = self else { return }
            self.dataModels = dataModels
            DispatchQueue.main.async {
                self.tableView.reloadData()
                }
            
        }

        viewModel.fetchWeatherInfo()
    }
}


extension WeatherInfoDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Today's temperature"
        } else if section == 1 {
            return "Today's forecast"
        } else {
            return "Wind Information"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        let infoModel = self.dataModels[indexPath.section][indexPath.row]

        cell?.textLabel?.text = infoModel.title
        cell?.detailTextLabel?.text = infoModel.subTitle
        return cell ?? UITableViewCell()
    }
    
    
}


