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
    
    init( navigationController: UINavigationController?, appCenter: AppCenter ) {
        self._navigationController = navigationController
        self.appCenter = appCenter
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MovieDetailController") as? MovieDetailController else {
            fatalError("MovieDetailController does not exist in storyboard.")
        }
        let viewModel = MovieDetailViewModel(coordinator: self,
                                             movieInteractor: appCenter.movieInteractor, 
                                             imageInteractor: appCenter.imageInteractor)
        vc.viewModel = viewModel
        self.viewController = vc
        self._navigationController?.pushViewController( vc, animated: true)
    }
    
    func back() {
        
    }

}
