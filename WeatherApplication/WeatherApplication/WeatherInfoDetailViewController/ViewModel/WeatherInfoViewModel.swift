//
//  WeatherInfoViewModel.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 27/06/21.
//

import Foundation

class WeatherInfoViewModel {
    
    var apiServices: ApiService?
    
    var updateUIHandler: (([[WeatherInfoModel]])->Void)?
    
    let locationDetail: LocationDetail
    
    init(with locationDetail: LocationDetail) {
        self.locationDetail = locationDetail
    }

    func fetchWeatherInfo() {
        let parameters = ["lat": String(locationDetail.latitude), "lon": String(locationDetail.longitude)]
        let configuration = APIServiceConfiguration(params: parameters, apiPath: .getWeatherInfo)
        self.apiServices = ApiService(configuration: configuration)
        apiServices?.request { responseData in
            
            do {
                let result = try JSONDecoder().decode(WeatherResponseModel.self, from: responseData)
                self.prepareDataSource(weatherResponseModel: result)
            } catch let e {
                print(e)
            }
    
        } errorHandler: { error in
            print(error)
        }
    }
    
    private func prepareDataSource(weatherResponseModel: WeatherResponseModel) {
        
        var resultArr: [[WeatherInfoModel]] = []
        
        var mainArr: [WeatherInfoModel] = []
        let main = weatherResponseModel.main
        let infoModel1 = WeatherInfoModel(title: "Today's Temp" , subTitle: String(main.temp))
        mainArr.append(infoModel1)
        
        let infoModel2 = WeatherInfoModel(title: "Min temp" , subTitle: String(main.tempMin))
        mainArr.append(infoModel2)
        
        let infoModel3 = WeatherInfoModel(title: "Max temp" , subTitle: String(main.tempMax))
        mainArr.append(infoModel3)
        
        let infoModel4 = WeatherInfoModel(title: "Feels like" , subTitle: String(main.feelsLike))
        mainArr.append(infoModel4)
        
        let infoModel5 = WeatherInfoModel(title: "Pressure" , subTitle: String(main.pressure))
        mainArr.append(infoModel5)
        
        let infoModel6 = WeatherInfoModel(title: "Humidity" , subTitle: String(main.humidity))
        mainArr.append(infoModel6)
        resultArr.append(mainArr)
        
        var weathers: [WeatherInfoModel] = []
        if let weather = weatherResponseModel.weather.first {
            let infoModel = WeatherInfoModel(title: "Weather condition", subTitle: weather.weatherDescription)
            weathers.append(infoModel)
        }
        resultArr.append(weathers)
        
        
        var winds: [WeatherInfoModel] = []
        if let windInfo = weatherResponseModel.wind {
            let infoModel7 = WeatherInfoModel(title: "Wind Speed" , subTitle: String(windInfo.speed))
            winds.append(infoModel7)
            
            let infoModel8 = WeatherInfoModel(title: "Degree" , subTitle: String(windInfo.deg))
            winds.append(infoModel8)
        }
        resultArr.append(winds)
        updateUIHandler?(resultArr)
    }
    
    
    
}
