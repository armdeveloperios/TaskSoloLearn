//
//  RequestsManager.swift
//  TaskSoloLearn
//
//  Created by Armen Alikhanyan on 4/19/19.
//  Copyright © 2019 ArmenAlikhanyan. All rights reserved.
//

import UIKit
import Alamofire

class RequestsManager: NSObject {
    //MARK: - Properties
    static let shared = RequestsManager()
    private let APIKey = "&api-key=ff984399-488d-4009-9dd2-74255e5ab511"
    private let baseURL = "https://content.guardianapis.com/search?format=json&show-fields=thumbnail,bodyText"
    private let page = "&page="
    private var pageNumber = 1
    
    // MARK: - Private init
    private override init() {}
    
    //MARK: - Public API
    func refreshNews(successCompletion: @escaping (_ result: [News]) -> (), failure: @escaping () -> ()) {
        pageNumber = 1
        self.getNews(successCompletion: { (reponse: [News]) in
            successCompletion(reponse)
        }) {
            failure()
        }
    }

    func getNews(successCompletion: @escaping (_ result: [News]) -> (), failure: @escaping () -> ())
    {
        let urlString = baseURL + page + "\(pageNumber)" + APIKey
        if let url = URL(string: urlString) {
            
            Alamofire.request(url).responseJSON { (response) in
                if response.result.isSuccess {
                    if response.response?.statusCode == 200 {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                            let jsonDecoder = JSONDecoder()
                            let responseData = try jsonDecoder.decode(DataJson.self, from: jsonData)
                            if let results = responseData.response?.results {
                                successCompletion(results)
                                // Update next loading page number
                                self.pageNumber += 1
                            } else {
                                // no results
                                failure()
                            }
                        } catch {
                            // parsing error
                            print(error)
                            failure()
                        }
                    } else {
                        failure()
                    }
                } else {
                    failure()
                    if response.result.error != nil {
                        print(response.result.error!)
                    }
                }
            }
        }
    }

}
