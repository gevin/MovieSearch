//
//  MovieDetailViewModel.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift

protocol MovieDetailViewModelType: ViewModelType {
    
    // input
    func bookMovie()
    
    // output
    var image: Driver<ImageState> {get}
    var synopsis: Driver<String> {get}
    var genres: Driver<String> {get}
    var language: Driver<String> {get}
    var duration: Driver<Int> {get}
    var loading: Driver<Bool> {get}
    var error: Driver<Error> {get}
    var isBooked: Driver<Bool> {get}
}

class MovieDetailViewModel: MovieDetailViewModelType {
    
    let coordinator: MovieDetailCoordinator
    let movieInteractor: MovieInteractor
    let imageInteractor: ImageInteractor
    
    var movieId: Int64 = 0
    
    private var _image = BehaviorRelay<ImageState>(value: ImageState.none)
    private var _synopsis = BehaviorRelay<String>(value: "")
    private var _genres = BehaviorRelay<String>(value: "")
    private var _language = BehaviorRelay<String>(value: "")
    private var _duration = BehaviorRelay<Int>(value: 0)
    private var _isBooked = BehaviorRelay<Bool>(value: false)
    private var _loadingTrack = ActivityIndicator()
    private var _errorTrack = ErrorTracker()
    
    var disposeBag = DisposeBag()
    
    var notifyToken: NotificationToken? = nil
    
    deinit {
        notifyToken?.invalidate()
        print("MovieDetailViewModel dealloc")
    }
    
    init( coordinator: MovieDetailCoordinator, movieInteractor: MovieInteractor, imageInteractor: ImageInteractor, movieId: Int64 ) {
        self.coordinator     = coordinator
        self.movieInteractor = movieInteractor
        self.imageInteractor = imageInteractor
        self.movieId         = movieId
    }
    
    func initial() {
        
        let booked = self.movieInteractor.isBooked(movieId: self.movieId)
        _isBooked.accept(booked)
        
        // observe change of MovieDetail
        self.notifyToken = self.movieInteractor.observeMovieDetail(movieId: self.movieId, {[weak self] (change:ObjectChange) in
            guard let strongSelf = self else {return}
            switch change {
            case let .error(error):
                strongSelf._errorTrack.raiseError(error as Error)
            case let .change(changeProperties):
                for property in changeProperties {
                    switch property.name {
                    case "overview":
                        strongSelf._synopsis.accept(property.newValue as! String)
                    case "genres":
                        let list = property.newValue as? List<MovieGenreModel>
                        let names = list?.map({$0.name})
                        let genresString = names?.joined(separator: ",") ?? ""
                        strongSelf._genres.accept(genresString)
                    case "spoken_languages":
                        let list = property.newValue as? List<LanguageInfoModel>
                        let names = list?.map({$0.name})
                        let languagesString = names?.joined(separator: ",") ?? ""
                        strongSelf._language.accept(languagesString)
                    case "runtime":
                        strongSelf._duration.accept( property.newValue as? Int ?? 0 )
                    default:
                        break
                    }
                }
            case .deleted:
                strongSelf.notifyToken?.invalidate()
            }
        })
        
        // first load MovieDetail 
        self.movieInteractor.queryMovieDetail(movieId: self.movieId)
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .do(onNext: {[weak self] (model:MovieDetailModel) in
                guard let strongSelf = self else {return}
                
                // synopsis
                strongSelf._synopsis.accept(model.overview)
                
                // genres
                let genreNames = model.genres.map({$0.name})
                let genresString = genreNames.joined(separator: ",") 
                strongSelf._genres.accept(genresString)
                
                // language
                let langNames = model.spoken_languages.map({$0.name})
                let languagesString = langNames.joined(separator: ",")
                strongSelf._language.accept(languagesString)
                
                // duration
                strongSelf._duration.accept( model.runtime )
            })
            .flatMap({[weak self] (model:MovieDetailModel) -> Observable<ImageState> in
                guard let strongSelf = self else {return Observable.empty()}
                // download image, if backdrop image is nil, then continue to download poster image 
                if model.backdrop_path.count > 0 {
                    return strongSelf.imageInteractor.getBackdropImage(backdropPath: model.backdrop_path, sizeLevel: 1)
                } else if model.poster_path.count > 0 {
                    return strongSelf.imageInteractor.getPosterImage(posterPath: model.poster_path, sizeLevel: 1)
                } else {
                    return Observable.of(ImageState.completed(nil))
                }
            })
            .bind(to: self._image )
            .disposed(by: self.disposeBag)
    }
    
    func refresh() {
        self.movieInteractor.reloadMovieDetail(movieId: self.movieId)
            .trackActivity(self._loadingTrack)
            .trackError(self._errorTrack)
            .do(onNext: {[weak self] (model:MovieDetailModel) in
                guard let strongSelf = self else {return}
                
                // synopsis
                strongSelf._synopsis.accept(model.overview)
                
                // genres
                let genreNames = model.genres.map({$0.name})
                let genresString = genreNames.joined(separator: ",") 
                strongSelf._genres.accept(genresString)
                
                // language
                let langNames = model.spoken_languages.map({$0.name})
                let languagesString = langNames.joined(separator: ",")
                strongSelf._language.accept(languagesString)
                
                // duration
                strongSelf._duration.accept( model.runtime )
            })
            .flatMap({[weak self] (model:MovieDetailModel) -> Observable<ImageState> in
                guard let strongSelf = self else {return Observable.empty()}
                // backdrop
                return strongSelf.imageInteractor.getBackdropImage(backdropPath: model.backdrop_path, sizeLevel: 1)
            })
            .bind(to: self._image )
            .disposed(by: self.disposeBag)
    }
}

// MARK: - Input
extension MovieDetailViewModel {
    func bookMovie() {
        if self.movieInteractor.isBooked(movieId: self.movieId) {
            self.movieInteractor.unBookMovie(movieId: self.movieId)
            _isBooked.accept(false)
        } else {
            self.movieInteractor.bookMovie(movieId: self.movieId)
            _isBooked.accept(true)
        }
    }
}

// MARK: - Output
extension MovieDetailViewModel {
    var image: Driver<ImageState> {return self._image.asDriver()}
    var synopsis: Driver<String> {return self._synopsis.asDriver()}
    var genres: Driver<String> {return self._genres.asDriver()}
    var language: Driver<String> {return self._language.asDriver()}
    var duration: Driver<Int> {return self._duration.asDriver()}
    var loading: Driver<Bool> {return self._loadingTrack.asDriver()}
    var error: Driver<Error> {return self._errorTrack.asDriver()}
    var isBooked: Driver<Bool> {return self._isBooked.asDriver()}
}
