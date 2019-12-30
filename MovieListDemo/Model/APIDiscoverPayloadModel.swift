//
//  APIResponse.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/29.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

struct APIDiscoverPayloadModel: Decodable {

   var page: Int // 1,
   var total_results: Int //10000,
   var total_pages: Int //500,
   var results: [MovieBriefModel]
    
}
