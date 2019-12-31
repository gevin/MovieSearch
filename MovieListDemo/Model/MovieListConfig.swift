//
//  MovieListConfig.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/31.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Realm
import RealmSwift

class MovieListConfig: Object {
    
    @objc dynamic var dataNumOfPage: Int = 0 //
    @objc dynamic var loadedPage: Int = 0 
    
}
