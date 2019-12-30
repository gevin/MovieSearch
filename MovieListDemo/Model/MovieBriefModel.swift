//
//  MovieModel.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/29.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class MovieBriefModel: Object, Decodable  {
    
    @objc dynamic var popularity: Float = 0.0 // 1.865
    @objc dynamic var id: Int64 = 0 // 432374
    @objc dynamic var video: Bool = false //false
    @objc dynamic var vote_count: Int = 0 //1
    @objc dynamic var vote_average: Float = 0 // 10
    @objc dynamic var title: String = "" // "Dawn French Live: 30 Million Minutes"
    @objc dynamic var release_date: Date? = nil // "2016-12-31"
    @objc dynamic var original_language: String = "" // "en"
    @objc dynamic var original_title: String = "" // "Dawn French Live: 30 Million Minutes"
    @objc dynamic var backdrop_path: String = "" //"/27RY4W57D6HWlY3FPmSphiIXco0.jpg"
    @objc dynamic var adult: Bool = false //false
    @objc dynamic var overview: String = "" // "Dawn French stars in her acclaimed one-woman show, the story of her life, filmed during its final West End run."
    @objc dynamic var poster_path: String = "" //"/67JLdcyxZfpNYLJTUocVvodAtAW.jpg"
    let genre_ids = List<Int>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private enum CodingKeys: String, CodingKey {
        case popularity 
        case id
        case video
        case vote_count
        case vote_average
        case title
        case release_date
        case original_language
        case original_title
        case backdrop_path
        case adult
        case overview
        case poster_path
        case genre_ids
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
       
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        popularity        = try container.decodeIfPresent(Float.self  , forKey: .popularity        ) ?? 0.0
        id                = try container.decodeIfPresent(Int64.self  , forKey: .id                ) ?? 0
        video             = try container.decodeIfPresent(Bool.self   , forKey: .video             ) ?? false
        vote_count        = try container.decodeIfPresent(Int.self    , forKey: .vote_count        ) ?? 0
        vote_average      = try container.decodeIfPresent(Float.self  , forKey: .vote_average      ) ?? 0.0
        title             = try container.decodeIfPresent(String.self , forKey: .title             ) ?? "" 
        if let dateString = try container.decodeIfPresent(String.self , forKey: .release_date      ) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.release_date = formatter.date(from: dateString)
        }
        original_language = try container.decodeIfPresent(String.self , forKey: .original_language ) ?? ""
        original_title    = try container.decodeIfPresent(String.self , forKey: .original_title    ) ?? ""
        backdrop_path     = try container.decodeIfPresent(String.self , forKey: .backdrop_path     ) ?? ""
        adult             = try container.decodeIfPresent(Bool.self   , forKey: .adult             ) ?? false
        overview          = try container.decodeIfPresent(String.self , forKey: .overview          ) ?? ""
        poster_path       = try container.decodeIfPresent(String.self , forKey: .poster_path       ) ?? ""
        if let genres = try container.decodeIfPresent([Int].self  , forKey: .genre_ids         ) {
            genre_ids.append(objectsIn: genres)
        }
    }
}
