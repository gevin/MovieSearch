//
//  RLMResultsExtension.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/27.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Realm
import RealmSwift

extension Results {

    func toArray() -> [Element] {
        return compactMap { $0 }
    }
    
}
