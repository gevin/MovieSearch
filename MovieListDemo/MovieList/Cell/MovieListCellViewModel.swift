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
    var imageUrl: String
    var image: BehaviorRelay<ImageState> 
    var title: BehaviorRelay<String>
    var popularity: BehaviorRelay<Float>
    
    init() {
        self.image = BehaviorRelay<ImageState>(value: .none)
        self.title = BehaviorRelay<String>(value: "")
        self.popularity = BehaviorRelay<Float>(value: 0.0) 
        self.imageUrl = ""
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
