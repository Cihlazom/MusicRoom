//
//  NetworkManager.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//

import UIKit
import Alamofire

class NetworkService {
    func fetchTracks(searchText: String, completion: @escaping (SearchResponse?) -> Void) {
        let url = "https://itunes.apple.com/search"
        let parametrs = ["term":"\(searchText)",
                         "media":"music",
                         "limit":"20"]
        
        AF.request(url, method: .get, parameters: parametrs).responseData { data in
            guard data.error == nil else {
                print(data.error?.localizedDescription ?? "")
                completion(nil)
                return
            }
            
            guard let data = data.data else {
                completion(nil)
                print("failed to get data")
                return
            }
            
            do {
                let model = try JSONDecoder().decode(SearchResponse.self, from: data)
                completion(model)
            } catch {
                print("Error")
                completion(nil)
            }
        }
    }
}
