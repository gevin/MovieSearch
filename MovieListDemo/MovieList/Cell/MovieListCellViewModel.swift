//
//  MovieListViewModel.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct MovieListCellViewModel: IdentifiableType, Equatable {
    
    var identity: Int64
    var backdropUrl: String
    var posterUrl: String
    var image: BehaviorRelay<ImageState> 
    var title: BehaviorRelay<String>
    var popularity: BehaviorRelay<Float>
    var booked: BehaviorRelay<Bool>
    
    init() {
        self.image = BehaviorRelay<ImageState>(value: .none)
        self.title = BehaviorRelay<String>(value: "")
        self.popularity = BehaviorRelay<Float>(value: 0.0)
        self.booked = BehaviorRelay<Bool>(value: false)
        self.backdropUrl = ""
        self.posterUrl = ""
        self.identity = 0
    }
    
    // MARK: - Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.identity == rhs.identity {
            return true
        }
        return false
    }
    
}
