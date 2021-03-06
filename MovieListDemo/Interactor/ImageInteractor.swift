//
//  ImageInteractor.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/27.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import SDWebImage
import Moya

enum ImageInteractorError: Error {
    case sizeLevelOutOfBounds(String)
    case invalidImagePath(String)
}

enum ImageState {
    case none
    case completed(_ image: UIImage? )
    case loading
    case error(_ error: Error? )
}

protocol ImageInteractorType: InteractorType {
    
    func getImageConfiguration() -> Observable<ImageConfiguration>
    
    func getBackdropImage( backdropPath: String, sizeLevel: Int )  -> Observable<ImageState>
    
    func getPosterImage( posterPath: String, sizeLevel: Int )  -> Observable<ImageState>
    
    func getImage( urlString: String ) -> Observable<ImageState>
    
}

class ImageInteractor: ImageInteractorType {
    
    var apiClient: APIClient
    
    var realm: Realm
    
    var downloadTaskDict:[String:Observable<ImageState>] = [:]
    
    var disposeBag = DisposeBag()
    
    private var _requestImageConfiguration: Observable<ImageConfiguration>?
    
    init( apiClient: APIClient, realm: Realm) {
        self.apiClient = apiClient
        self.realm = realm
    }
    
    /// https://developers.themoviedb.org/3/configuration/get-api-configuration
    /// The information regards to download image 
    func getImageConfiguration() -> Observable<ImageConfiguration> {
        // 重覆呼叫時，只會回傳第一次呼叫的 observable
        if let request = _requestImageConfiguration {
            return request
        }
        
        let request = self.apiClient.getConfiguration()
            .observeOn(MainScheduler.instance)
            .debug()
            .map(ImageConfiguration.self, atKeyPath: "images")
            .do(onNext: {[weak self] (imgConfiguration) in
                guard let strongSelf = self else {return}
                let result = strongSelf.realm.objects(ImageConfiguration.self)
                try! strongSelf.realm.write {
                    strongSelf.realm.delete(result)
                    strongSelf.realm.add(imgConfiguration)
                }
            }, onCompleted: {[weak self] in
                guard let strongSelf = self else {return}
                strongSelf._requestImageConfiguration = nil
            })
            .share(replay: 1)
        
        _requestImageConfiguration = request
        return request
    }
    
    /// give backdrop path and compose a whole image url, then download image 
    func getBackdropImage( backdropPath: String, sizeLevel: Int )  -> Observable<ImageState> {
        guard backdropPath.count > 0 else { return Observable.error(ImageInteractorError.invalidImagePath("backdropPath is empty."))}
        let result = self.realm.objects(ImageConfiguration.self)
        if result.count == 0 {
            return self.getImageConfiguration()
                    .flatMapLatest { (imgConfiguration) -> Observable<ImageState> in
                        let imgConfiguration = result[0]
                        let baseUrl = imgConfiguration.secure_base_url
                        if imgConfiguration.backdrop_sizes.count > sizeLevel {
                            let size = imgConfiguration.backdrop_sizes[sizeLevel]
                            let imageUrl = "\(baseUrl)\(size)\(backdropPath)"
                            return self.getImage(urlString: imageUrl)
                        } else {
                            return Observable.error( ImageInteractorError.sizeLevelOutOfBounds("backdrop sizes \(sizeLevel) out of bound \(imgConfiguration.backdrop_sizes.count)"))
                        }
                    }
        }
        else {
            let imgConfiguration = result[0]
            let baseUrl = imgConfiguration.secure_base_url
            if imgConfiguration.backdrop_sizes.count > sizeLevel {
                let size = imgConfiguration.backdrop_sizes[sizeLevel]
                let imageUrl = "\(baseUrl)\(size)\(backdropPath)"
                return self.getImage(urlString: imageUrl)
            } else {
                return Observable.error( ImageInteractorError.sizeLevelOutOfBounds("backdrop sizes \(sizeLevel) out of bound \(imgConfiguration.backdrop_sizes.count)"))
            }
        }
    }
    
    func getPosterImage( posterPath: String, sizeLevel: Int )  -> Observable<ImageState> {
        guard posterPath.count > 0 else { return Observable.error(ImageInteractorError.invalidImagePath("backdropPath is empty."))}
        let result = self.realm.objects(ImageConfiguration.self)
        if result.count == 0 {
            return self.getImageConfiguration()
                    .flatMapLatest { (imgConfiguration) -> Observable<ImageState> in
                        let imgConfiguration = result[0]
                        let baseUrl = imgConfiguration.secure_base_url
                        if imgConfiguration.poster_sizes.count > sizeLevel {
                            let size = imgConfiguration.backdrop_sizes[sizeLevel]
                            let imageUrl = "\(baseUrl)\(size)\(posterPath)"
                            return self.getImage(urlString: imageUrl)
                        } else {
                            return Observable.error( ImageInteractorError.sizeLevelOutOfBounds("poster sizes \(sizeLevel) out of bound \(imgConfiguration.backdrop_sizes.count)"))
                        }
                    }
        }
        else {
            let imgConfiguration = result[0]
            let baseUrl = imgConfiguration.secure_base_url
            if imgConfiguration.poster_sizes.count > sizeLevel {
                let size = imgConfiguration.backdrop_sizes[sizeLevel]
                let imageUrl = "\(baseUrl)\(size)\(posterPath)"
                return self.getImage(urlString: imageUrl)
            } else {
                return Observable.error( ImageInteractorError.sizeLevelOutOfBounds("poster sizes \(sizeLevel) out of bound \(imgConfiguration.backdrop_sizes.count)"))
            }
        }
    }
    
    /// retrieve image from local cache or download image from server 
    func getImage( urlString: String ) -> Observable<ImageState> {
        guard let url = URL(string: urlString) else { return Observable.of(ImageState.completed(nil))}
        // downloading
        if let runningTask = downloadTaskDict[urlString] {
            return runningTask
        }
        
        if let image = SDImageCache.shared.imageFromMemoryCache(forKey: urlString) {
            return Observable.of(ImageState.completed(image))
        }
        
        if let image = SDImageCache.shared.imageFromDiskCache(forKey: urlString) {
            SDImageCache.shared.storeImage(toMemory: image, forKey: urlString)
            return Observable.of(ImageState.completed(image))
        }
        
        let downloadImageTask = Observable<ImageState>.create({ (observer) -> Disposable in
        
            observer.onNext(ImageState.loading)
            
            //SDWebImageDownloader.shared.setValue("", forHTTPHeaderField: "ETag")
            SDWebImageDownloader.shared.downloadImage(with: url, completed: {[weak self] (imageOrNil:UIImage?, dataOrNil:Data?, errorOrNil:Error?, finish:Bool)  in
                
                if let error = errorOrNil {
                    observer.onNext(ImageState.error(error))
                    observer.onCompleted()
                    self?.downloadTaskDict[urlString] = nil
                    return
                }
                
                SDImageCache.shared.storeImage(toMemory: imageOrNil, forKey: urlString)
                SDImageCache.shared.storeImageData(toDisk: imageOrNil?.sd_imageData(), forKey: urlString)
                observer.onNext(ImageState.completed(imageOrNil))
                observer.onCompleted()
                
                self?.downloadTaskDict[urlString] = nil
            })
            
            return Disposables.create()
        }).share(replay: 1)
        
        downloadTaskDict[urlString] = downloadImageTask
        return downloadImageTask
    }
}
