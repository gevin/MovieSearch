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
    
    init( apiClient: APIClient, realm: Realm ) {
        self.apiClient = apiClient
        self.realm = realm
        
        self.movieInteractor = MovieInteractor(apiClient: self.apiClient, realm: self.realm)
        self.imageInteractor = ImageInteractor(apiClient: self.apiClient, realm: self.realm)
        
    }

}
