//
//  MovieDetailCoordinator.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MovieDetailCoordinator: CoordinatorType {
    
    weak var viewController: UIViewController?
    
    var childCoordinators: [CoordinatorType] = []
    
    private var _navigationController: UINavigationController?
    
    let appCenter: AppCenter
    
    var disposeBag = DisposeBag()
    
    var didFinish = PublishSubject<CoordinatorType?>()
    
    var movieId: Int64 = 0
    
    deinit {
        print("MovieDetailCoordinator dealloc")
    }
    
    init( navigationController: UINavigationController?, appCenter: AppCenter, movieId: Int64 ) {
        self._navigationController = navigationController
        self.appCenter = appCenter
        self.movieId = movieId
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MovieDetailController") as? MovieDetailController else {
            fatalError("MovieDetailController does not exist in storyboard.")
        }
        let viewModel = MovieDetailViewModel(coordinator: self,
                                             movieInteractor: appCenter.movieInteractor, 
                                             imageInteractor: appCenter.imageInteractor,
                                             movieId: self.movieId )
        vc.viewModel = viewModel
        self.viewController = vc
        self._navigationController?.pushViewController( vc, animated: true)
        
        // observe dismiss or pop
        vc.rx.viewWillDisappear
        .filter({[weak self] _ in (self?.viewController?.isMovingFromParent ?? false) })
        .map({[weak self] (_) -> CoordinatorType? in
            return self
        })
        .bind(to: didFinish)
        .disposed(by: self.disposeBag)
    }
    
    func back() {
        self._navigationController?.popViewController(animated: true)
    }

}
