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
    var cellHeight: CGFloat
    var disposeBag = DisposeBag()
    
    init() {
        self.image = BehaviorRelay<ImageState>(value: .none)
        self.title = BehaviorRelay<String>(value: "")
        self.popularity = BehaviorRelay<Float>(value: 0.0)
        self.booked = BehaviorRelay<Bool>(value: false)
        self.backdropUrl = ""
        self.posterUrl = ""
        self.identity = 0
        self.cellHeight = 0
    }
    
    // MARK: - Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.identity == rhs.identity {
            return true
        }
        return false
    }
    
    func calculateHeight(fixedWidth: CGFloat) -> CGFloat {
        var height:CGFloat = 0.0
        var imageHeight:CGFloat = 0.0
        switch self.image.value {
        case let .completed(imageOrNil):
            if let size = imageOrNil?.size {
                let factor = fixedWidth / size.width 
                imageHeight = size.height * factor
            } else {
                imageHeight = 160
            }
            
            break
        case .none, .error(_), .loading:
            imageHeight = 160
        default:
            imageHeight = 160
        }
        
        // popularity height
        var popularityString = "\(self.popularity.value)"
        var popularityHeight:CGFloat = popularityString.height(withConstrainedWidth: fixedWidth, font: UIFont.systemFont(ofSize: 14.0))
        
        // title height
        var titleHeight:CGFloat = self.title.value.height(withConstrainedWidth: fixedWidth, font: UIFont.systemFont(ofSize: 17.0))
        
        return CGFloat(8 + imageHeight + 8 + popularityHeight + 8 + titleHeight + 12)
    }
    
}
