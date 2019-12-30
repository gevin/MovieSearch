//
//  MovieDetailModel.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/29.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class MovieDetailModel: Object, Decodable {
    
    @objc dynamic var adult : Bool = false
    @objc dynamic var backdrop_path : String = "" //"/3DrUqTAPjriEasoGrz5G8sPJtDU.jpg"
    @objc dynamic var budget : Int64 = 0 //75000000
    @objc dynamic var homepage : String = "" //"http://www.thesecretlifeofpets.com/"
    @objc dynamic var id : Int64 = 0 //328111
    @objc dynamic var imdb_id : String = "" //"tt2709768"
    @objc dynamic var original_language : String = "" //"en"
    @objc dynamic var original_title : String = "" //"The Secret Life of Pets"
    @objc dynamic var overview : String = "" //"The quiet life of a terrier named Max is upended when his owner takes in Duke, a stray whom Max instantly dislikes."
    @objc dynamic var popularity : Float = 0.0 //9.777
    @objc dynamic var poster_path : String = "" //"/WLQN5aiQG8wc9SeKwixW7pAR8K.jpg"
    @objc dynamic var release_date : String = "" //"2016-06-18"
    @objc dynamic var revenue : Int64 = 0 //875457937
    @objc dynamic var runtime : Int = 0 //87
    @objc dynamic var status : String = "" //"Released"
    @objc dynamic var tagline : String = "" //"Think this is what they do all day?"
    @objc dynamic var title : String = "" //"The Secret Life of Pets"
    @objc dynamic var video : Bool = false
    @objc dynamic var vote_average : Float = 0.0 //6.1
    @objc dynamic var vote_count : Int = 0 //5802
    let belongs_to_collection = List<MovieCollectionModel>() 
    let genres = List<MovieGenreModel>()
    let production_companies = List<MovieProductionCompanyModel>()
    let production_countries = List<CountryInfoModel>()
    let spoken_languages = List<LanguageInfoModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private enum CodingKeys: String, CodingKey {
        case adult
        case backdrop_path
        case belongs_to_collection 
        case budget
        case genres
        case homepage
        case id
        case imdb_id
        case original_language
        case original_title
        case overview
        case popularity
        case poster_path
        case production_companies
        case production_countries
        case release_date
        case revenue
        case runtime
        case spoken_languages
        case status
        case tagline
        case title
        case video
        case vote_average
        case vote_count
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
        self.adult                  = try container.decodeIfPresent(Bool.self  , forKey: .adult ) ?? false
        self.backdrop_path          = try container.decodeIfPresent(String.self, forKey: .backdrop_path ) ?? ""
        self.budget                 = try container.decodeIfPresent(Int64.self , forKey: .budget ) ?? 0
        self.homepage               = try container.decodeIfPresent(String.self, forKey: .homepage ) ?? ""
        self.id                     = try container.decodeIfPresent(Int64.self , forKey: .id ) ?? 0
        self.imdb_id                = try container.decodeIfPresent(String.self, forKey: .imdb_id ) ?? ""
        self.original_language      = try container.decodeIfPresent(String.self, forKey: .original_language ) ?? ""
        self.original_title         = try container.decodeIfPresent(String.self, forKey: .original_title ) ?? ""
        self.overview               = try container.decodeIfPresent(String.self, forKey: .overview ) ?? ""
        self.popularity             = try container.decodeIfPresent(Float.self , forKey: .popularity ) ?? 0.0
        self.poster_path            = try container.decodeIfPresent(String.self, forKey: .poster_path ) ?? ""
        self.release_date           = try container.decodeIfPresent(String.self, forKey: .release_date ) ?? ""
        self.revenue                = try container.decodeIfPresent(Int64.self , forKey: .revenue ) ?? 0
        self.runtime                = try container.decodeIfPresent(Int.self   , forKey: .runtime ) ?? 0
        self.status                 = try container.decodeIfPresent(String.self, forKey: .status ) ?? ""
        self.tagline                = try container.decodeIfPresent(String.self, forKey: .tagline ) ?? ""
        self.title                  = try container.decodeIfPresent(String.self, forKey: .title ) ?? ""
        self.video                  = try container.decodeIfPresent(Bool.self  , forKey: .video ) ?? false
        self.vote_average           = try container.decodeIfPresent(Float.self , forKey: .vote_average ) ?? 0.0
        self.vote_count             = try container.decodeIfPresent(Int.self   , forKey: .vote_count ) ?? 0
        if let movieCollections  = try container.decodeIfPresent([MovieCollectionModel].self, forKey: .belongs_to_collection  ) {
            self.belongs_to_collection.append(objectsIn: movieCollections)
        }
        if let movieGenres = try container.decodeIfPresent([MovieGenreModel].self, forKey: .genres ) {
            self.genres.append(objectsIn: movieGenres)
        }
        if let companies = try container.decodeIfPresent([MovieProductionCompanyModel].self, forKey: .production_companies ) {
            self.production_companies.append(objectsIn: companies)
        }
        if let countries = try container.decodeIfPresent([CountryInfoModel].self, forKey: .production_countries ) {
            self.production_countries.append(objectsIn: countries)
        }
        if let languages = try container.decodeIfPresent([LanguageInfoModel].self, forKey: .spoken_languages ) {
            self.spoken_languages.append(objectsIn: languages)
        }
    }
    
}


class MovieGenreModel: Object, Decodable {
    
    @objc dynamic var id: Int64 //12,
    @objc dynamic var name: String //"Adventure"
    
    override static func primaryKey() -> String? {
        return "id"
    }

}


class MovieCollectionModel: Object, Decodable {
    
    @objc dynamic var id: Int64 //33,
    @objc dynamic var logo_path: String // "/8lvHyhjr8oUKOOy2dKXoALWKdp0.png",
    @objc dynamic var name: String //"Universal Pictures",
    @objc dynamic var origin_country: String //"US"
    
    override static func primaryKey() -> String? {
        return "id"
    }

}


class MovieProductionCompanyModel: Object, Decodable {

    @objc dynamic var id: Int64 //33,
    @objc dynamic var logo_path: String //"/8lvHyhjr8oUKOOy2dKXoALWKdp0.png",
    @objc dynamic var name: String //"Universal Pictures",
    @objc dynamic var origin_country: String //"US"
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
