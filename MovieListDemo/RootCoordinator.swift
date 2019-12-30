//
//  RootCoordinator.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RootCoordinator: CoordinatorType {
    
    weak var viewController: UIViewController?
    
    var childCoordinators: [CoordinatorType] = []
    
    private var _navigationController: UINavigationController?
    
    let appCenter: AppCenter
    
    var disposeBag = DisposeBag()
    
    required init(navigationController: UINavigationController?, appCenter: AppCenter ) {
        self._navigationController = navigationController
        self.appCenter = appCenter
    }
    
    func start() {
        self.gotoMovieList()
    }
    
    func back() {
        
    }
    
    func gotoMovieList() {
        let coordinator = MovieListCoordinator(navigationController: self._navigationController, appCenter: appCenter)
        coordinator.start()
    }
}
