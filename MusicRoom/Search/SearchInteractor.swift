//
//  SearchInteractor.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var networkService = NetworkService()
    var presenter: SearchPresentationLogic?
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        switch request {
        case .getTracks(let searchTerm):
            presenter?.presentData(response: Search.Model.Response.ResponseType.presentFooterView)
            networkService.fetchTracks(searchText: searchTerm) { [weak self] response in
                self?.presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks(searchResponse: response))
            }
        }
    }
    
}
