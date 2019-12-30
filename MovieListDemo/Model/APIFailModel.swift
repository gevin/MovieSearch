//
//  APIErrorModel.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/29.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

// Error
struct APIFailModel: Decodable {
    var status_code: Int //7,
    var status_message: String //"Invalid API key: You must be granted a valid key.",
    var success: Bool //false
}
