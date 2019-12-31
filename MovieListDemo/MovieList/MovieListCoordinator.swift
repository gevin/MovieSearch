//
//  MovieListCoordinator.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MovieListCoordinator: CoordinatorType {
    
    weak var viewController: UIViewController?
    
    var childCoordinators: [CoordinatorType] = []
    
    private var _navigationController: UINavigationController?
    
    let appCenter: AppCenter
    
    var disposeBag = DisposeBag()
    
    init( navigationController: UINavigationController?, appCenter: AppCenter ) {
        self._navigationController = navigationController
        self.appCenter = appCenter
    }

    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MovieListController") as? MovieListController else {
            fatalError("MovieListController does not exist in storyboard.")
        }
        let viewModel = MovieListViewModel(coordinator: self,
                                           movieInteractor: appCenter.movieInteractor, 
                                           imageInteractor: appCenter.imageInteractor)
        vc.viewModel = viewModel
        self.viewController = vc
        self._navigationController?.pushViewController( vc, animated: false)
    }
    
    func back() {
        
    }
    
    func gotoMovieDetail( movieId: Int64 ) {
        let nextCoordinator = MovieDetailCoordinator(navigationController: self._navigationController, appCenter: self.appCenter, movieId: movieId)
        self.childCoordinators.append(nextCoordinator)
        nextCoordinator.start()
        // remove nextCoordinator while pop
        nextCoordinator.didFinish.subscribe(onNext: { (coordinatorOrNil:CoordinatorType?) in
            guard let coordinator = coordinatorOrNil else { return }
            if let index = self.childCoordinators.firstIndex(where: { ($0 === coordinator ) }) {
                self.childCoordinators.remove(at: index)
            }
        })
        .disposed(by: disposeBag)
    }

}
