//
//  CountryInfoModel.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/29.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class CountryInfoModel: Object, Decodable {
    
    @objc dynamic var iso_3166_1: String //"US",
    @objc dynamic var name: String //"United States of America"
    
    override static func primaryKey() -> String? {
        return "iso_3166_1"
    }
    
}
