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
import RealmSwift
import Realm
import SDWebImage

protocol MovieListViewModelType: ViewModelType {
    
    // input 
    func selectMovie( movieCellVM: MovieListCellViewModel )
    func loadNextPage()
    
    // output
    var movieList: Driver<[MovieListCellViewModel]> {get}
    var loading: Driver<Bool> {get}
    var error: Driver<Error> {get}
    var loadedPages: Int {get}
}

class MovieListViewModel: MovieListViewModelType {
    
    private var _loadingTrack     = ActivityIndicator()
    private var _errorTrack       = ErrorTracker()
    private var _movieCellVMs     = BehaviorRelay<[MovieListCellViewModel]>(value: [])
    private var _movieBriefModels = [MovieBriefModel]()
    var disposeBag                = DisposeBag()
    
    var loadedPages: Int = 0
    var dataNumberOfPage: Int = 0

    let coordinator: MovieListCoordinator
    let movieInteractor: MovieInteractor
    let imageInteractor: ImageInteractor
    
    var notifyToken: NotificationToken? = nil
    
    deinit {
        notifyToken?.invalidate()
    }
    
    init( coordinator: MovieListCoordinator, movieInteractor: MovieInteractor, imageInteractor: ImageInteractor) {
        self.coordinator     = coordinator
        self.movieInteractor = movieInteractor
        self.imageInteractor = imageInteractor
    }
    
    /// ViewModel initial
    func initial() {
        // observer Model update
        notifyToken = self.movieInteractor.observeMovieList {[weak self] (changes:RealmCollectionChange<Results<MovieBriefModel>>) in
            guard let strongSelf = self else {return}
            switch changes {
            case .initial(let collection):
                print("initial")
                if collection.count > 0 {
                    strongSelf.append(models: collection.toArray())
                }
                break
            case .update(let collection, let deletions, let insertions, let modifications):
                
                strongSelf.append(models: collection.toArray())
                break
            case .error(let err):
                strongSelf._errorTrack.raiseError(err)
                break
            }
        }
        
        loadedPages = 1
        self.imageInteractor.getImageConfiguration() // download Image Configuration
            .flatMap({[weak self] (_) -> Observable<[MovieBriefModel]> in  // and then load movie list
                guard let strongSelf = self else {return Observable.empty()}
                return strongSelf.movieInteractor.queryMovieBriefList(page: 1)
            })
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .subscribe(onNext: { (result:[MovieBriefModel]) in
                print(result[0].backdrop_path)
            })
            .disposed(by: self.disposeBag)
    }
    
    /// reload local MovieBriefModel Data.
    /// It would be clear all MovieBriefModel data in Realm and refetch data from server.
    func refresh() {
        
        self._movieBriefModels.removeAll()
        self.movieInteractor.reloadMovieBriefList()
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .subscribe(onNext: {[weak self] (results:[MovieBriefModel]) in
                guard let strongSelf = self else {return}
                
            })
            .disposed(by: disposeBag)
    }
    
    /// Append local model array
    /// - Parameter models: MovieBriefModel array
    private func append( models:[MovieBriefModel] ) {
        // 新的在前
        let array = models.sorted { (m1, m2) -> Bool in
            let time1 = m1.release_date?.timeIntervalSince1970 ?? 0 
            let time2 = m2.release_date?.timeIntervalSince1970 ?? 0 
            return time1 > time2 
        }
        self._movieBriefModels.append(contentsOf: models)
        let cellVMs = self.mapMovieListViewModel(models: self._movieBriefModels)
        self._movieCellVMs.accept(cellVMs)     
    }
    
    /// Model -> ViewModel
    /// - Parameter models: MovieBriefModel array
    private func mapMovieListViewModel( models:[MovieBriefModel] ) -> [MovieListCellViewModel] {
        let cellVMs = models.map { (model:MovieBriefModel) -> MovieListCellViewModel in
            var cellVM = MovieListCellViewModel()
            cellVM.identity = model.id
            cellVM.imageUrl = model.backdrop_path
            cellVM.title.accept( model.title )
            cellVM.popularity.accept(model.popularity)
            // download image 
            if cellVM.imageUrl.count > 0 {
                imageInteractor.getBackdropImage(backdropPath: cellVM.imageUrl, sizeLevel: 0)
                    .bind(to: cellVM.image)
                    .disposed(by: disposeBag)
            }
            return cellVM
        }
        return cellVMs
    }
    
}


// MARK: - input

extension MovieListViewModel {
    
    func selectMovie( movieCellVM: MovieListCellViewModel ) {
        // move to detail
        self.coordinator.gotoMovieDetail(movieId: movieCellVM.identity)
    }
    
    func loadNextPage() {
        loadedPages += 1
        self.movieInteractor.queryMovieBriefList(page: loadedPages)
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .subscribe(onNext: { ([MovieBriefModel]) in
                
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - output

extension MovieListViewModel {
    
    var movieList: Driver<[MovieListCellViewModel]> { return _movieCellVMs.asDriver() }
    var loading: Driver<Bool> { return self._loadingTrack.asDriver() }
    var error: Driver<Error> { return self._errorTrack.asDriver()}
    
}
