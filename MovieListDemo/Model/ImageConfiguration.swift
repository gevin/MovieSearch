//
//  ImageConfiguration.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ImageConfiguration: Object, Decodable {

    @objc dynamic var base_url: String = ""
    @objc dynamic var secure_base_url: String = ""
    let backdrop_sizes = List<String>()
    let logo_sizes = List<String>()
    let poster_sizes = List<String>()
    let profile_sizes = List<String>()
    let still_sizes = List<String>()
    
    private enum CodingKeys: String, CodingKey {
        case base_url 
        case secure_base_url
        case backdrop_sizes
        case logo_sizes
        case poster_sizes
        case profile_sizes
        case still_sizes
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
        base_url        = try container.decodeIfPresent(String.self  , forKey: .base_url        ) ?? ""
        secure_base_url = try container.decodeIfPresent(String.self  , forKey: .secure_base_url ) ?? ""
        if let sizes    = try container.decodeIfPresent([String].self, forKey: .backdrop_sizes  ) { backdrop_sizes.append(objectsIn: sizes) }
        if let sizes    = try container.decodeIfPresent([String].self, forKey: .logo_sizes      ) { logo_sizes.append(objectsIn: sizes)}
        if let sizes    = try container.decodeIfPresent([String].self, forKey: .poster_sizes    ) { poster_sizes.append(objectsIn: sizes)}
        if let sizes    = try container.decodeIfPresent([String].self, forKey: .profile_sizes   ) { profile_sizes.append(objectsIn: sizes)}
        if let sizes    = try container.decodeIfPresent([String].self, forKey: .still_sizes     ) { still_sizes.append(objectsIn: sizes)}
    }
    
}
