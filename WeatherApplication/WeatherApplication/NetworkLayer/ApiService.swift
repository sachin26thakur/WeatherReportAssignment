//
//  ApiService.swift
//  WeatherApplication
//
//  Created by Sachin Thakur on 24/06/21.
//

import Foundation

enum MethodType: String {
    case get = "GET"
    case post = "POST"
    case update = "UPDATE"
    case delete = "DELETE"
}


enum NetworkError: String, Error {
    case internetNotAvailable
    case invalidURL
    case parser
    case unknown
    case timeout
    case cancelled
}


enum ApiPath: String {
    case getWeatherInfo
}

class ApiBundlePath { }

struct APIServiceConfiguration {
    let methodType: MethodType
    let apiPath: ApiPath
    var parameter: [String: String]
    
    private func getAPIKeyDictionary() -> [String: String] {
        let apiKey = "4949b3026cd8890d63a1bd890df7683f"
        return ["appid": apiKey]
    }
    
    init(methodType: MethodType = .get, params: [String: String], apiPath: ApiPath) {
        self.methodType = methodType
        self.apiPath = apiPath
        self.parameter = params
    }
    
    private func apiDictionary(fileName: String) -> [String: String]? {
        guard let apiPListUrl = Bundle(for: ApiBundlePath.self)
            .url(forResource: fileName,
                 withExtension: "plist") else {
                    return nil
        }
        return NSDictionary(contentsOf: apiPListUrl) as? [String: String]
    }
    
    func getMethodURL() -> URL? {
        let apiPath =  self.apiDictionary(fileName: "WeatherApi")
//        let url = URL(string: apiPath?[ApiPath.getWeatherInfo.rawValue] ?? "")

        var components = URLComponents(string: (apiPath?[ApiPath.getWeatherInfo.rawValue])!)!
        let params = self.parameter.merged(with: self.getAPIKeyDictionary())
        components.queryItems = params.map { (key, value) in
                URLQueryItem(name: key, value: value)
        }

        return components.url
    }
    
}

class ApiService {
    
    let configuration: APIServiceConfiguration
    let session = URLSession.shared
    
    init(configuration: APIServiceConfiguration) {
        self.configuration = configuration
    }
    
    func request(with completionHandler: @escaping (Data) -> Void, errorHandler: @escaping (NetworkError)-> Void ) {
    
        guard let url = self.configuration.getMethodURL() else {
            errorHandler(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = self.configuration.methodType.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = session.dataTask(with: request) { ( data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                errorHandler(.unknown)
                return
            }
            
            if error != nil {
                errorHandler(.unknown)
                return
            }
            
            guard let data = data else {
                errorHandler(.unknown)
                return
            }
                        
            completionHandler(data)
        }
        
        task.resume()
    }
}

extension Dictionary {

    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }

    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}
