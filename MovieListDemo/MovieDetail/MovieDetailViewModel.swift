//
//  MovieDetailViewModel.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit

protocol MovieDetailViewModelType: ViewModelType {
    
}

class MovieDetailViewModel: MovieDetailViewModelType {
    
    let coordinator: MovieDetailCoordinator
    let movieInteractor: MovieInteractor
    let imageInteractor: ImageInteractor
    
    init( coordinator: MovieDetailCoordinator, movieInteractor: MovieInteractor, imageInteractor: ImageInteractor) {
        self.coordinator     = coordinator
        self.movieInteractor = movieInteractor
        self.imageInteractor = imageInteractor
    }
    
    func initial() {
        
    }
    
    func refresh() {
        
    }

    // Book this movie
    
}
