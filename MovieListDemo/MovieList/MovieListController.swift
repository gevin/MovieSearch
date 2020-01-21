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
                if var layout = strongSelf.collectionView.collectionViewLayout as? MyLayout {
                    layout.model = list
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
        
        collectionView.collectionViewLayout = MyLayout()
//        if var layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            let width = UIScreen.main.bounds.size.width
//            layout.estimatedItemSize = CGSize(width: width-32, height: 10)
//        }
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
            .filter({$0})
            .do(onNext: {[weak self] (_) in
                guard let strongSelf = self else {return}
                // trigger load next page
                strongSelf.viewModel?.loadNextPage()
                strongSelf.isLoadMore = true
            })
            .flatMap({ (_) -> Observable<Event<[MovieListSectionModel]>> in
                return dataSource.dataReloded.asObservable() // observe collectionView reloadData completed event
            })
            .filter({_ in self.isLoadMore})
            .subscribe(onNext: {[weak self] (_) in
                guard let strongSelf = self else {return}
                strongSelf.isLoadMore = false
            })
            .disposed(by: self.disposeBag)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if var layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
        }
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if var layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: view.bounds.size.width, height: 10)
            layout.invalidateLayout()
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
}

extension MovieListController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellViewModel = self.sectionRelay.value[indexPath.section].items[indexPath.row]
        self.viewModel?.selectMovie(movieId: cellViewModel.identity)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellViewModel = self.sectionRelay.value[indexPath.section].items[indexPath.row]
        if cellViewModel.cellHeight == 0 {
            cellViewModel.cellHeight = cellViewModel.calculateHeight(fixedWidth: UIScreen.main.bounds.size.width-32)
        }
        return CGSize(width: UIScreen.main.bounds.size.width-32, height: cellViewModel.cellHeight)
    }
}


class MyLayout: UICollectionViewLayout {
    
    var model: [MovieListCellViewModel] = []
    
    var contentHeight: CGFloat = 0
    
    var cache: [UICollectionViewLayoutAttributes] = []
    
    // Returns the width of the collection view 
    var width: CGFloat {
      return collectionView!.bounds.width
    }
    
    // Returns the height of the collection view 
    var height: CGFloat {
      return collectionView!.bounds.height
    }
    
    // Returns the number of items in the collection view 
    var numberOfItems: Int {
        if model.count > 0 {
            return collectionView!.numberOfItems(inSection: 0)
        }
        return 0
    }

}

// MARK: UICollectionViewLayout

extension MyLayout {

    /// keep calling while scrolling.
    override func prepare() {
        cache.removeAll(keepingCapacity: false)
    
        let smallScale: CGFloat = 0.5
        let standardScale: CGFloat = 1.0
  
        var frame = CGRect.zero
        var itemY: CGFloat = 0
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            // Important because each cell has to slide over the top of the previous one 
            attributes.zIndex = item
            
            if model[item].cellHeight == 0 {
                model[item].cellHeight = model[item].calculateHeight(fixedWidth: self.width - 32)
            }
            let itemHeight: CGFloat = model[item].cellHeight  
            
            // Initially set the height of the cell to the standard height
            var transform = CATransform3DIdentity
            transform.m34 = -2.5 / 2000.0
            transform = CATransform3DTranslate(transform, 10, 0, -150.0)
            transform = CATransform3DRotate(transform, CGFloat.pi * (-30.0/180.0), 1.0, 0.0, 0.0)
            
            var interpolate = (itemY - collectionView!.contentOffset.y)
            if interpolate < 0 { interpolate = 0 }
            if interpolate > 150 { interpolate = 150 }
            interpolate = interpolate/150.0
            let scale = 0.8 + ( (1.0 - 0.8) * interpolate)
            transform = CATransform3DScale(transform, scale, scale, 1.0)
            attributes.transform3D = transform
                
            var bounds = CGRect(x: 0, y: 0, width: self.width - 32, height: itemHeight)
            let transformedBounds = bounds.applying( CATransform3DGetAffineTransform(transform) )
//            print("\(item) transform:\(transformedBounds.size.height), original:\(itemHeight)")

            frame = CGRect(x: 0, y: itemY, width: self.width - 32, height: transformedBounds.size.height )
            attributes.bounds = bounds
            attributes.frame = frame
            cache.append(attributes)
            itemY = frame.maxY - (transformedBounds.size.height*0.2)
        }
        contentHeight = itemY
    }
    
    // Return the size of all the content in the collection view 
    override var collectionViewContentSize : CGSize {
        return CGSize(width: width, height: contentHeight)
    }
  
    // Return all attributes in the cache whose frame intersects with the rect passed to the method 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
  
    // 會拉回定點，像 page 那樣 
    // Return the content offset of the nearest cell which achieves the nice snapping effect, similar to a paged UIScrollView 
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        let itemIndex = round(proposedContentOffset.y / dragOffset)
//        let yOffset = itemIndex * dragOffset
//        return CGPoint(x: 0, y: yOffset)
//    }

    // Return true so that the layout is continuously invalidated as the user scrolls 
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
