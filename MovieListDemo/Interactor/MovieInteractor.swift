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


protocol MovieInteractorType : InteractorType {
    
}

class MovieInteractor: MovieInteractorType {
    
    let apiClient: APIClient
    
    let realm: Realm
    
    init( apiClient: APIClient, realm: Realm) {
        self.apiClient = apiClient
        self.realm = realm
    }
    
//    func getArticleModel( newsId: String ) -> ArticleModel? {
//        let model = self.realm.object(ofType: ArticleModel.self, forPrimaryKey: newsId)
//        
//        return model
//    }
//    
//    func updateArticleContent( model: ArticleModel, newContent: String  ) {
//        try! self.realm.write {
//            model.content = newContent
//        }
//    }
    
    func queryMovieBriefList(page: Int) -> Observable<[MovieBriefModel] > {
        let result = self.realm.objects(MovieBriefModel.self)
        if result.count > 0 {
            return Observable.of(result.toArray())
        }
        
        var movieQueryData = MovieDiscoverQuery()
        movieQueryData.page = UInt(page)
        movieQueryData.primary_release_date_lte = "2016-12-31"
        movieQueryData.sort_by = MovieSortBy.release_date_desc
        
        return self.apiClient.movieDiscover(querys: movieQueryData)
            .debug()
            .map([MovieBriefModel].self, atKeyPath: "results")
            .do(onNext: {[weak self] (models:[MovieBriefModel]) in
                guard let strongSelf = self else { return }
                do {
                    try strongSelf.realm.write {
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
    
    func observeMovieList(_ callback: @escaping (RealmCollectionChange<Results<MovieBriefModel>>) -> Void ) -> NotificationToken? {
        let result = self.realm.objects(MovieBriefModel.self)
        let token = result.observe(callback)
        return token
    }
}
