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

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

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
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var refreshControl: UIRefreshControl = UIRefreshControl(frame: CGRect.zero)
    
    var sectionRelay = BehaviorRelay<[MovieListSectionModel]>( value: [MovieListSectionModel(header: "", items: [])] )
    
    var isLoadMore: Bool = false
    
    var original_offset: CGPoint = CGPoint.zero
    
    var noDataView = NoDataView.create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionViewConfigure()
        self.bindUI()
        self.viewModel?.initial()
    }
    
    func bindUI() {
        
        // if no data, clicked refresh
        self.noDataView.reloadButton.rx.tap.throttle(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] () in
                guard let strongSelf = self else {return}
                strongSelf.viewModel?.refresh()
            })
            .disposed(by: disposeBag)
        
        // receive data
        self.viewModel?.movieList
            .drive(onNext: {[weak self] (list:[MovieListCellViewModel]) in
                guard let strongSelf = self else {return}
                var sections = strongSelf.sectionRelay.value
                if sections.count == 0 {
                    sections.append( MovieListSectionModel(header: "", items: []) )
                }
                if list.count == 0 {
                    strongSelf.collectionView.backgroundView = strongSelf.noDataView
                } else {
                    strongSelf.collectionView.backgroundView = nil
                    sections[0].items = list
                    strongSelf.sectionRelay.accept(sections)
                }
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
        
        // config cell
        let dataSource = MyCollectionDataSource<MovieListSectionModel>(configureCell: { (_, collectionView, indexPath, model: MovieListCellViewModel ) -> UICollectionViewCell in
            let cell = MovieListCell.cellWith(collectionView: collectionView, indexPath: indexPath)
            cell.configure(viewModel: model, collectionView: collectionView, indexPath: indexPath)
            return cell
        })
        
        // bind data source
        self.sectionRelay.bind(to: self.collectionView.rx.items(dataSource: dataSource) ).disposed(by: disposeBag)
        
//        // reload data
//        dataSource.dataReloded.asObservable()
//            .subscribe(onNext: {[weak self] (event:Event<[MovieListSectionModel]>) in
//                guard let strongSelf = self else {return}
//                // pull down to refresh
//                if !strongSelf.isLoadMore {
//                    strongSelf.collectionView.contentOffset = CGPoint.zero
//                }
//            })
//            .disposed(by: self.disposeBag)
        
        // load more
        collectionView.rx.contentOffset
            .filter({_ in 
                // scroll to bottom and not loading 
                return self.collectionView.isNearBottomEdge(edgeOffset: 20.0) && !self.isLoadMore 
            })
            .withLatestFrom(self.rx.viewDidAppear)
            .flatMap { state in state ? Signal.just(()) : Signal.empty() }
            .do(onNext: {[weak self] () in
                guard let strongSelf = self else {return}
                
                // save original offset
                strongSelf.original_offset = strongSelf.collectionView.contentOffset
                
                // trigger load next page
                strongSelf.viewModel?.loadNextPage()
                strongSelf.isLoadMore = true
            })
            .flatMap({ () -> Observable<Event<[MovieListSectionModel]>> in
                return dataSource.dataReloded.asObservable() // observe collectionView reloadData completed event
            })
            .filter({_ in self.isLoadMore})
            .subscribe(onNext: {[weak self] (_) in
                guard let strongSelf = self else {return}
                // when reload completed, adjust content offset to previous position and set isLoadMore = false 
                //print("offset:\(strongSelf.collectionView.contentOffset)")
                strongSelf.collectionView.setContentOffset(strongSelf.original_offset, animated: false)
                strongSelf.isLoadMore = false
            })
            .disposed(by: self.disposeBag)
    }
}

extension MovieListController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellViewModel = self.sectionRelay.value[indexPath.section].items[indexPath.row]
        self.viewModel?.selectMovie(movieId: cellViewModel.identity)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellViewModel = self.sectionRelay.value[indexPath.section].items[indexPath.row]
        cellViewModel.cellHeight = cellViewModel.calculateHeight(fixedWidth: UIScreen.main.bounds.size.width - 16)
        return CGSize(width: UIScreen.main.bounds.size.width - 16, height: cellViewModel.cellHeight)
    }
}
