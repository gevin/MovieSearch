//
//  LanguageInfoModel.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/29.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class LanguageInfoModel: Object, Decodable {
    @objc dynamic var iso_639_1: String //"en",
    @objc dynamic var name: String //"English"
    
    override static func primaryKey() -> String? {
        return "iso_639_1"
    }
}
