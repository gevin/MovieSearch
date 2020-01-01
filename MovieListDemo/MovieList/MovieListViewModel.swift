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
    func selectMovie( movieId: Int64 )
    func loadNextPage()
    
    // output
    var movieList: Driver<[MovieListCellViewModel]> {get}
    var loading: Driver<Bool> {get}
    var isLoading: Bool {get}
    var error: Driver<Error> {get}
     
}

class MovieListViewModel: MovieListViewModelType {

    private var _loadingTrack      = ActivityIndicator()
    private var _errorTrack        = ErrorTracker()
    private var _movieCellVMs      = BehaviorRelay<[MovieListCellViewModel]>(value: [])
    private var _movieBriefModels  = [MovieBriefModel]()
    var disposeBag                 = DisposeBag()

    let coordinator: MovieListCoordinator
    let movieInteractor: MovieInteractorType
    let imageInteractor: ImageInteractorType
    
    var movieNotifyToken: NotificationToken? = nil
    
    deinit {
        movieNotifyToken?.invalidate()
    }
    
    init( coordinator: MovieListCoordinator, movieInteractor: MovieInteractorType, imageInteractor: ImageInteractorType) {
        self.coordinator     = coordinator
        self.movieInteractor = movieInteractor
        self.imageInteractor = imageInteractor
    }
    
    /// ViewModel initial
    func initial() {
        
        // subscribe Book event
        self.movieInteractor.bookedEvent
            .subscribe(onNext: {[weak self] (movieId:Int64) in
                guard let strongSelf = self else {return}
                if let vm = strongSelf._movieCellVMs.value.first(where: {$0.identity == movieId}) {
                    vm.booked.accept(true)
                }
            })
            .disposed(by: self.disposeBag)
        
        self.movieInteractor.unbookedEvent
            .subscribe(onNext: {[weak self] (movieId:Int64) in
                guard let strongSelf = self else {return}
                if let vm = strongSelf._movieCellVMs.value.first(where: {$0.identity == movieId}) {
                    vm.booked.accept(false)
                }
            })
            .disposed(by: self.disposeBag)
        
        // observe MovieBriefModel update
        movieNotifyToken = self.movieInteractor.observeMovieList {[weak self] (changes:RealmCollectionChange<Results<MovieBriefModel>>) in
            guard let strongSelf = self else {return}
            switch changes {
            case .initial(let collection):
                print("initial")
                if collection.count > 0 {
                    strongSelf.appendModels(collection.toArray())
                }
                break
            case .update(let collection, let deletions, let insertions, let modifications):
                // collection is final results
                // deletions , insertions , odifications are object indeis in collection 
                print("update.. page:\(strongSelf.movieInteractor.loadedPage())")
                break
            case .error(let err):
                strongSelf._errorTrack.raiseError(err)
                break
            }
        }
        
//        self.appendModels([])
        self.imageInteractor.getImageConfiguration() // download Image Configuration
            .flatMap({[weak self] (_) -> Observable<[MovieBriefModel]> in  // and then load movie list
                guard let strongSelf = self else {return Observable.empty()}
                return strongSelf.movieInteractor.loadNextPageMovieBriefList()
            })
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .subscribe(onNext: {[weak self] (result:[MovieBriefModel]) in
                guard let strongSelf = self else {return}
                strongSelf.appendModels(result)
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
            .subscribe(onNext: {[weak self] (result:[MovieBriefModel]) in
                guard let strongSelf = self else {return}
                strongSelf.removeAllModel()
                strongSelf.appendModels(result)
            })
            .disposed(by: disposeBag)
    }
    
    /// Append local model array
    /// - Parameter models: MovieBriefModel array
    private func appendModels(_ models:[MovieBriefModel] ) {
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
    
    /// clear viewmodel cache
    private func removeAllModel() {
        self._movieBriefModels.removeAll()
    }
    
    /// Model -> ViewModel
    /// - Parameter models: MovieBriefModel array
    private func mapMovieListViewModel( models:[MovieBriefModel] ) -> [MovieListCellViewModel] {
        let cellVMs = models.map { (model:MovieBriefModel) -> MovieListCellViewModel in
            var cellVM = MovieListCellViewModel()
            cellVM.identity = model.id
            cellVM.backdropUrl = model.backdrop_path
            cellVM.posterUrl = model.poster_path
            cellVM.title.accept( model.title )
            cellVM.popularity.accept(model.popularity)
            cellVM.booked.accept( self.movieInteractor.isBooked(movieId: model.id) )
            // download image, if backdrop image is nil, then continue to download poster image 
            if cellVM.backdropUrl.count > 0 {
                imageInteractor.getBackdropImage(backdropPath: cellVM.backdropUrl, sizeLevel: 0)
                    .bind(to: cellVM.image)
                    .disposed(by: disposeBag)
            } else if cellVM.posterUrl.count > 0 {
                imageInteractor.getPosterImage(posterPath: cellVM.posterUrl, sizeLevel: 0)
                    .bind(to: cellVM.image)
                    .disposed(by: disposeBag)
            } else {
                cellVM.image.accept(.completed(nil))
                print("\(model.id) no image")
            }
            return cellVM
        }
        return cellVMs
    }
    
    
}

// MARK: - input

extension MovieListViewModel {
    
    func selectMovie( movieId: Int64 ) {
        // move to detail
        self.coordinator.gotoMovieDetail(movieId: movieId)
    }
    
    func loadNextPage() {
        self.movieInteractor.loadNextPageMovieBriefList()
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .subscribe(onNext: {[weak self] (result:[MovieBriefModel]) in
                guard let strongSelf = self else {return}
                strongSelf.appendModels(result)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - output

extension MovieListViewModel {
    
    var movieList: Driver<[MovieListCellViewModel]> { return _movieCellVMs.skip(1).asDriverOnErrorJustComplete() }
    var loading: Driver<Bool> { return self._loadingTrack.asDriver() }
    var error: Driver<Error> { return self._errorTrack.asDriver()}
    var isLoading: Bool {return self._loadingTrack.count > 0}
}
