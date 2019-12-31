//
//  AppCenter.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class AppCenter {
    
    let apiClient: APIClient
    let realm: Realm 
    let movieInteractor: MovieInteractor
    let imageInteractor: ImageInteractor
    
    private static var _instance: AppCenter?
    static func initial( apiClient: APIClient, realm: Realm ) {
        let instance = AppCenter( apiClient: apiClient, realm: realm)
        _instance = instance
    }
    static let shared: AppCenter = { return _instance! }()
    
    private init( apiClient: APIClient, realm: Realm ) {
        self.apiClient = apiClient
        self.realm = realm
        
        self.movieInteractor = MovieInteractor(apiClient: self.apiClient, realm: self.realm)
        self.imageInteractor = ImageInteractor(apiClient: self.apiClient, realm: self.realm)
    }

}
