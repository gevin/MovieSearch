//
//  ViewController.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/27.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Realm
import RealmSwift
import SVProgressHUD

struct MovieListSectionModel {
    var header: String
    var items:[MovieListCellViewModel]
}

extension MovieListSectionModel: AnimatableSectionModelType {
    typealias Item = MovieListCellViewModel
    typealias Identity = String
    
    var identity: String {
        return header
    }

    init(original: MovieListSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

class MovieListController: UIViewController, ViewType {
    
    var viewModel: MovieListViewModelType?

    var movieInteractor: MovieInteractor? = nil
    var apiClient: APIClient?
    var realm: Realm?
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var refreshControl: UIRefreshControl = UIRefreshControl(frame: CGRect.zero)
    
    var sectionRelay = BehaviorRelay<[MovieListSectionModel]>( value: [MovieListSectionModel(header: "", items: [])] )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionViewConfigure()
        self.bindUI()
        self.viewModel?.initial()
    }
    
    func bindUI() {
        
        self.viewModel?.movieList
            .drive(onNext: {[weak self] (list:[MovieListCellViewModel]) in
                guard let strongSelf = self else {return}
                var sections = strongSelf.sectionRelay.value
                if sections.count == 0 {
                    sections.append( MovieListSectionModel(header: "", items: []) )
                }
                sections[0].items = list
                strongSelf.sectionRelay.accept(sections)
            })
            .disposed(by: disposeBag)
        
        self.viewModel?.loading
            .drive(onNext: { (isLoading:Bool) in
                if isLoading {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            })
            .disposed(by: disposeBag)
        
        self.viewModel?.error
            .drive(onNext: { (error:Error) in
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func collectionViewConfigure() {
        
        self.collectionView.delegate = self
        
        // pulldown to refresh 
        if #available( iOS 10.0, *) {
            self.collectionView.refreshControl = self.refreshControl
            let refresh_size = self.collectionView.refreshControl?.bounds.size
            self.collectionView.refreshControl?.bounds = CGRect(x: 0, y: 0, width: refresh_size?.width ?? 0, height: refresh_size?.height ?? 0)
        } else {
            self.collectionView.addSubview(refreshControl)
            let refresh_bounds = CGRect(x: 0, y: 0, width: self.collectionView.bounds.size.width , height: 44 )
            refreshControl.bounds = refresh_bounds
        }
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh")
        refreshControl
            .rx
            .controlEvent(.valueChanged)
            .asObservable()
            .subscribe {[weak self] (_) in
                guard let strongSelf = self else {return}
                strongSelf.refreshControl.endRefreshing()
                strongSelf.viewModel?.refresh()
            }.disposed(by: self.disposeBag)
        
        // register cell
        self.collectionView.register(UINib(nibName: "MovieListCell", bundle: nil), forCellWithReuseIdentifier: "MovieListCell")
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width - 32, height: 50)
        }
        // config cell
        let dataSource = RxCollectionViewSectionedReloadDataSource<MovieListSectionModel>(configureCell: { (_, collectionView, indexPath, model: MovieListCellViewModel ) -> UICollectionViewCell in
            let cell = MovieListCell.cellWith(collectionView: collectionView, indexPath: indexPath)
            model.title
                .bind(to: cell.titleLabel.rx.text )
                .disposed(by: cell.disposeBag)
            model.popularity
                .map({"\($0)"})
                .bind(to: cell.popularityLabel.rx.text)
                .disposed(by: cell.disposeBag)
            model.image
                .bind(to: cell.backdropImageView.rx.state)
                .disposed(by: cell.disposeBag)
            return cell
        })
        self.sectionRelay.bind(to: self.collectionView.rx.items(dataSource: dataSource) ).disposed(by: disposeBag)

    }

    @IBAction func testClicked(_ sender: Any) {
        
        var movieQueryData = MovieDiscoverQuery()
        movieQueryData.page = 1
        movieQueryData.primary_release_date_lte = "2016-12-31"
        movieQueryData.sort_by = MovieSortBy.release_date_desc
        
        self.apiClient?.movieDiscover(querys: movieQueryData)
            .debug()
            .mapJSON()
            .subscribe(onNext: { (result) in
                print(result)
            })
            .disposed(by: self.disposeBag)
        
    }
    
}

extension MovieListController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
