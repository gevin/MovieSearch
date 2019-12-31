//
//  MovieInteractor.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya
import Alamofire
import Realm
import RealmSwift

enum MovieInteractorError: Error {
    case invalidMovieId
    case invalidPage
    case movieDetailNotExist
}

protocol MovieInteractorType : InteractorType {
    
    // Movie List
    func loadNextPageMovieBriefList() -> Observable<[MovieBriefModel] >
    func reloadMovieBriefList() -> Observable<[MovieBriefModel] >
    
    // Movie Detail
    func queryMovieDetail( movieId: Int64 ) -> Observable<MovieDetailModel>
    func reloadMovieDetail( movieId: Int64 ) -> Observable<MovieDetailModel>
    
    // Book Movie
    func isBooked(movieId: Int64) -> Bool
    func unBookMovie( movieId: Int64 )
    func bookMovie( movieId: Int64 )
    func getAllBookedMovies() -> [BookedMovie]
    
    // Observe
    func observeMovieList(_ callback: @escaping (RealmCollectionChange<Results<MovieBriefModel>>) -> Void ) -> NotificationToken?
    func observeMovieDetail( movieId: Int64, _ callback: @escaping (ObjectChange) -> Void ) -> NotificationToken?
    // passing movieID
    var bookedEvent: Observable<Int64> {get}
    var unbookedEvent: Observable<Int64> {get}
    
}

class MovieInteractor: MovieInteractorType {
    
    let apiClient: APIClient
    
    let realm: Realm
    
    // passing movieID
    private var _bookedEvent = PublishSubject<Int64>()
    private var _unbookedEvent = PublishSubject<Int64>()
    
    init( apiClient: APIClient, realm: Realm) {
        self.apiClient = apiClient
        self.realm = realm
    }
    
    func getMovieListConfig() -> MovieListConfig {
        let result = self.realm.objects(MovieListConfig.self)
        if result.count == 0 {
            let model = MovieListConfig()
            try! self.realm.write {
                self.realm.add(model)
            }
            return model
        } else {
            return result[0]
        }
    }
    
    func loadedPage() -> Int {
        let model = self.getMovieListConfig()
        return model.loadedPage
    }
    
    // MARK: - Movie List
    
    func loadNextPageMovieBriefList() -> Observable<[MovieBriefModel] > {
        
        let movieListConfig = self.getMovieListConfig()
        // 記錄一頁幾筆資料
        try! self.realm.write {
            movieListConfig.loadedPage += 1
        }
        
        // query from server
        var movieQueryData = MovieDiscoverQuery()
        movieQueryData.page = UInt(movieListConfig.loadedPage)
        movieQueryData.primary_release_date_lte = "2016-12-31"
        movieQueryData.sort_by = MovieSortBy.release_date_desc
        
        return self.apiClient.movieDiscover(querys: movieQueryData)
            .observeOn(MainScheduler.instance)
            .debug()
            .map([MovieBriefModel].self, atKeyPath: "results")
            .do(onNext: {[weak self] (models:[MovieBriefModel]) in
                guard let strongSelf = self else { return }
                do {
                    try strongSelf.realm.write {
                        if movieListConfig.dataNumOfPage == 0 {
                            movieListConfig.dataNumOfPage = models.count 
                        }
                        strongSelf.realm.add(models)
                    }
                } catch {
                    print(error)
                }
            })
    }
    
    func reloadMovieBriefList() -> Observable<[MovieBriefModel] > {
        var movieQueryData = MovieDiscoverQuery()
        movieQueryData.page = 1
        movieQueryData.primary_release_date_lte = "2016-12-31"
        movieQueryData.sort_by = MovieSortBy.release_date_desc
        
        return self.apiClient.movieDiscover(querys: movieQueryData)
            .observeOn(MainScheduler.instance)
            .debug()
            .map([MovieBriefModel].self, atKeyPath: "results")
            .do(onNext: {[weak self] (models:[MovieBriefModel]) in
                guard let strongSelf = self else { return }
                do {
                    let result = strongSelf.realm.objects(MovieBriefModel.self)
                    try strongSelf.realm.write {
                        strongSelf.realm.delete(result)
                        strongSelf.realm.add(models)
                    }
                } catch {
                    print(error)
                }
            })
    }
    
    // MARK: - Movie Detail
    
    /// https://developers.themoviedb.org/3/movies/get-movie-details
    /// Get the primary information about a movie.
    func queryMovieDetail( movieId: Int64 ) -> Observable<MovieDetailModel> {
        
        if let model = self.realm.object(ofType: MovieDetailModel.self, forPrimaryKey: movieId) {
            return Observable.of(model)
        }
        
        // 取得 lang code, country code
        var languageCode = String(Locale.preferredLanguages[0].prefix(2)).lowercased()
        var regionCode = Locale.current.regionCode?.uppercased() ?? "US"
        if languageCode.count == 0 {
            languageCode = "en"
        }
        
        return self.apiClient.movieDetail(movieId: movieId, language: "\(languageCode)-\(regionCode)")
            .observeOn(MainScheduler.instance)
            .debug()
//            .do(onNext: {[weak self] (response) in
//                do {
//                    let dict = try JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions.allowFragments)
//                    //print("receive:\n\(dict)")
//                } catch {
//                    print(error)
//                }
//            })
            .map(MovieDetailModel.self)
            .do(onNext: {[weak self] (model:MovieDetailModel) in
                guard let strongSelf = self else { return }
                do {
                    try strongSelf.realm.write {
                        strongSelf.realm.add(model,update: .all)
                    }
                } catch {
                    print(error)
                }
            })
    }
    
    /// download new movie detail data, replace local cache
    func reloadMovieDetail( movieId: Int64 ) -> Observable<MovieDetailModel> {
        
        // 取得 lang code, country code
        var languageCode = String(Locale.preferredLanguages[0].prefix(2)).lowercased()
        var regionCode = Locale.current.regionCode?.uppercased() ?? "US"
        if languageCode.count == 0 {
            languageCode = "en"
        }
        
        return self.apiClient.movieDetail(movieId: movieId, language: "\(languageCode)-\(regionCode)")
            .observeOn(MainScheduler.instance)
            .debug()
            .map(MovieDetailModel.self, atKeyPath: "object")
            .do(onNext: {[weak self] (model:MovieDetailModel) in
                guard let strongSelf = self else { return }
                let object = strongSelf.realm.object(ofType: MovieDetailModel.self, forPrimaryKey: movieId)
                do {
                    try strongSelf.realm.write {
                        if object != nil {
                            strongSelf.realm.delete(object!)
                        }
                        strongSelf.realm.add(model)
                    }
                } catch {
                    print(error)
                }
            })
    }
    
    // MARK: - Book
    
    func isBooked(movieId: Int64) -> Bool {
        let result = self.realm.objects(BookedMovie.self).filter("movieId == %@", movieId)
        if result.count == 0 {
            return false
        }
        return true
    }
    
    func unBookMovie( movieId: Int64 ) {
        // has booked
        if let model = self.realm.object(ofType: BookedMovie.self, forPrimaryKey: movieId) {
            let result = self.realm.objects(BookedMovie.self)
            print("result:\(result)")
            // remove book record
            print("unbook:\(model.movieId)")
            try! self.realm.write {
                self.realm.delete(result)
            }
            self._unbookedEvent.onNext(movieId)
        }
    }
    
    func bookMovie( movieId: Int64 ) {
        
        // not book yet
        guard !self.isBooked(movieId: movieId) else {
            return
        }

        // create a new book record
        let bookData = BookedMovie()
        try! self.realm.write {
            bookData.booktime = Date().timeIntervalSince1970
            print("booked movieId:\(movieId)")
            bookData.movieId = movieId
            self.realm.add(bookData)
        }
        self._bookedEvent.onNext(movieId)
    }
    
    func getAllBookedMovies() -> [BookedMovie] {
        let result = self.realm.objects(BookedMovie.self)
        return result.toArray()
    }
    
    // MARK: - Observe
    
    func observeMovieList(_ callback: @escaping (RealmCollectionChange<Results<MovieBriefModel>>) -> Void ) -> NotificationToken? {
        let result = self.realm.objects(MovieBriefModel.self)
        let token = result.observe(callback)
        return token
    }
    
    func observeMovieDetail( movieId: Int64, _ callback: @escaping (ObjectChange) -> Void ) -> NotificationToken? {
        let model = self.realm.object(ofType: MovieDetailModel.self, forPrimaryKey: movieId)
        let token = model?.observe(callback)
        return token
    }
    
    // passing movieID
    var bookedEvent: Observable<Int64> {return _bookedEvent.asObservable()}
    var unbookedEvent: Observable<Int64> {return _unbookedEvent.asObservable()}
    
}
