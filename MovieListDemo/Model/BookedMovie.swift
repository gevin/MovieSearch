//
//  BookedMovie.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/31.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class BookedMovie: Object {
    
    @objc dynamic var movieId: Int64 = 0
    @objc dynamic var booktime: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "movieId"
    }
}
