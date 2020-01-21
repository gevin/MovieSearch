
//
//  APIClient.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/24.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya
import Alamofire

/*
 https://developers.themoviedb.org/3/getting-started/introduction
 
 */

enum MovieAPI {
    static let baseURLString = "https://api.themoviedb.org/3"
    case movieDiscover( querys: [String: Any] )
    case movieDetail( movieId: String, language: String? )
    case configuration()
    
}

extension MovieAPI: Moya.TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        return URL(string: MovieAPI.baseURLString)!
    }
    
    var path: String {
        switch self {
        case .movieDiscover:
            return "/discover/movie"
        case .movieDetail( let movieId, _):
            return "/movie/\(movieId)"
        case .configuration:
            return "/configuration"
        default:
            return "/discover/movie"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .movieDiscover:
            return .get
        case .movieDetail:
            return .get
        case .configuration:
            return .get
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        
        switch self {
        case .movieDiscover(let querys):
            return .requestParameters(parameters: querys, encoding: URLEncoding.default)
        case .movieDetail( _, let language):
            var params:[String : Any] = [:]
            params["language"] = language
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .configuration:
            return .requestPlain
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }

    var authorizationType: AuthorizationType {
        return .bearer
    }
    
}

class APIClient: NSObject {
    
    var providerHolder:[MoyaProvider<MovieAPI>] = []
    var provider = MoyaProvider<MovieAPI>()
    private var _api_key = "046025412164cdff60aa810d52a8d4ea"
    private var _token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwNDYwMjU0MTIxNjRjZGZmNjBhYTgxMGQ1MmE4ZDRlYSIsInN1YiI6IjVlMDgwMmYzYTFjNTlkMDAxOGE4MWJiMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.1vLBQn6oQo-GO_wkBTkIFIykmXZXvqxBNtp_zvbi0Ck"
    let queue = DispatchQueue(label: "com.gevinchen.moviediscover")
    
    override init() {
        super.init()
        let authPlugin = AccessTokenPlugin(tokenClosure: self._token)
        self.provider = MoyaProvider<MovieAPI>(plugins: [authPlugin])        
    }
    
    func refreshToken() {
        let authPlugin = AccessTokenPlugin(tokenClosure: self._token)
        self.provider = MoyaProvider<MovieAPI>(plugins: [authPlugin])
    }
    
    func movieDiscover( querys: MovieDiscoverQuery ) -> Observable<Response> {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(querys)
            let params = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [String : Any]
            
            let apiRequest =  provider.rx.request(.movieDiscover(querys: params ), callbackQueue: queue)
                .asObservable()
            return apiRequest
        } catch {
            return Observable.error(error)
        }
    }
    
    func movieDetail( movieId: Int64, language: String ) -> Observable<Response> {
        return provider.rx.request(.movieDetail(movieId: "\(movieId)", language: language), callbackQueue: queue)
            .asObservable()
    }
    
    func getConfiguration() -> Observable<Response> {
        let apiRequest =  provider.rx.request(.configuration(), callbackQueue: queue)
            .asObservable()
        return apiRequest
    }
    

}
