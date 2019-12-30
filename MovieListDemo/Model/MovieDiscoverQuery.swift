//
//  MovieDiscoverQuery.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/29.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit

enum MovieSortBy: String {
    case popularity_asc = "popularity.asc"
    case popularity_desc = "popularity.desc"
    case release_date_asc = "release_date.asc"
    case release_date_desc = "release_date.desc"
    case revenue_asc = "revenue.asc"
    case revenue_desc = "revenue.desc"
    case primary_release_date_asc = "primary_release_date.asc"
    case primary_release_date_desc = "primary_release_date.desc"
    case original_title_asc = "original_title.asc"
    case original_title_desc = "original_title.desc"
    case vote_average_asc = "vote_average.asc"
    case vote_average_desc = "vote_average.desc"
    case vote_count_asc = "vote_count.asc"
    case vote_count_desc = "vote_count.desc"
}

struct MovieDiscoverQuery: Encodable {
    var language: String?
    var region: String?
    var sort_by: MovieSortBy?
    var include_adult: Bool?
    var include_video: Bool?
    var page: UInt?  // minimum: 1 , maximum: 1000 , default: 1
    var primary_release_year: UInt?
    var primary_release_date_gte: String?
    var primary_release_date_lte: String?
    var release_date_gte: String?
    var release_date_lte: String?
    var with_release_type: String? // AND 123,123  OR 123|123 minimum: 1 maximum: 6
    var year: UInt? // specific year
    var vote_count_gte: UInt? // minimum: 0
    var vote_count_lte: UInt? // minimum: 1
    var vote_average_gte: UInt? // minimum: 0
    var vote_average_lte: UInt? // minimum: 0 
    var with_cast: String? // A comma separated list of person ID's. Only include movies that have one of the ID's added as an actor.
    var with_crew: String? // A comma separated list of person ID's. Only include movies that have one of the ID's added as a crew member.
    var with_people: String? //A comma separated list of person ID's. Only include movies that have one of the ID's added as a either a actor or a crew member.
    var with_companies: String? // A comma separated list of production company ID's. Only include movies that have one of the ID's added as a production company.
    var with_genres: String? // Comma separated value of genre ids that you want to include in the results.
    var without_genres: String? // Comma separated value of genre ids that you want to exclude from the results.
    var with_keywords: String? // A comma separated list of keyword ID's. Only includes movies that have one of the ID's added as a keyword.
    var without_keywords: String? // Exclude items with certain keywords. You can comma and pipe seperate these values to create an 'AND' or 'OR' logic.
    var with_runtime_gte: Int? // Filter and only include movies that have a runtime that is greater or equal to a value.
    var with_runtime_lte: Int? // Filter and only include movies that have a runtime that is less than or equal to a value.
    var with_original_language: String? //Specify an ISO 639-1 string to filter results by their original language value.
    
    private enum CodingKeys: String, CodingKey {
        case language
        case region
        case sort_by
        case include_adult
        case include_video
        case page
        case primary_release_year
        case primary_release_date_gte = "primary_release_date.gte"
        case primary_release_date_lte = "primary_release_date.lte"
        case release_date_gte         = "release_date.gte"
        case release_date_lte         = "release_date.lte"
        case with_release_type
        case year
        case vote_count_gte           = "vote_count.gte"
        case vote_count_lte           = "vote_count.lte"
        case vote_average_gte         = "vote_average.gte"
        case vote_average_lte         = "vote_average.lte"
        case with_cast
        case with_crew
        case with_people
        case with_companies
        case with_genres
        case without_genres
        case with_keywords
        case without_keywords
        case with_runtime_gte         = "with_runtime.gte"
        case with_runtime_lte         = "with_runtime.lte"
        case with_original_language
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent( self.language                 , forKey: .language                 )
        try container.encodeIfPresent( self.region                   , forKey: .region                   )
        try container.encodeIfPresent( self.sort_by?.rawValue        , forKey: .sort_by                  )
        try container.encodeIfPresent( self.include_adult            , forKey: .include_adult            )
        try container.encodeIfPresent( self.include_video            , forKey: .include_video            )
        try container.encodeIfPresent( self.page                     , forKey: .page                     )
        try container.encodeIfPresent( self.primary_release_year     , forKey: .primary_release_year     )
        try container.encodeIfPresent( self.primary_release_date_gte , forKey: .primary_release_date_gte )
        try container.encodeIfPresent( self.primary_release_date_lte , forKey: .primary_release_date_lte )
        try container.encodeIfPresent( self.release_date_gte         , forKey: .release_date_gte         )
        try container.encodeIfPresent( self.release_date_lte         , forKey: .release_date_lte         )
        try container.encodeIfPresent( self.with_release_type        , forKey: .with_release_type        )
        try container.encodeIfPresent( self.year                     , forKey: .year                     )
        try container.encodeIfPresent( self.vote_count_gte           , forKey: .vote_count_gte           )
        try container.encodeIfPresent( self.vote_count_lte           , forKey: .vote_count_lte           )
        try container.encodeIfPresent( self.vote_average_gte         , forKey: .vote_average_gte         )
        try container.encodeIfPresent( self.vote_average_lte         , forKey: .vote_average_lte         )
        try container.encodeIfPresent( self.with_cast                , forKey: .with_cast                )
        try container.encodeIfPresent( self.with_crew                , forKey: .with_crew                )
        try container.encodeIfPresent( self.with_people              , forKey: .with_people              )
        try container.encodeIfPresent( self.with_companies           , forKey: .with_companies           )
        try container.encodeIfPresent( self.with_genres              , forKey: .with_genres              )
        try container.encodeIfPresent( self.without_genres           , forKey: .without_genres           )
        try container.encodeIfPresent( self.with_keywords            , forKey: .with_keywords            )
        try container.encodeIfPresent( self.without_keywords         , forKey: .without_keywords         )
        try container.encodeIfPresent( self.with_runtime_gte         , forKey: .with_runtime_gte         )
        try container.encodeIfPresent( self.with_runtime_lte         , forKey: .with_runtime_lte         )
        try container.encodeIfPresent( self.with_original_language   , forKey: .with_original_language   )
    }
}
