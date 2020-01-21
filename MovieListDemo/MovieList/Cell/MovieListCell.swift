//
//  MovieListCell.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/30.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MovieListCell: UICollectionViewCell {
    
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var bookedLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    let noImageLabel = UILabel()
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.cornerRadius = 7
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.borderWidth = 1
        noImageLabel.text = "No Image"
        noImageLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        noImageLabel.textColor = UIColor.gray
        noImageLabel.textAlignment = .center
        noImageLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backdropImageView.setState(ImageState.none)
        titleLabel.text = ""
        popularityLabel.text = ""
        self.noImageLabel.removeFromSuperview()
        disposeBag = DisposeBag()
    }
    
    static func cellWith( collectionView: UICollectionView, indexPath: IndexPath ) -> Self {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Self.self), for: indexPath) as! Self
        return cell
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
       width.constant = bounds.size.width // add constraint to contentView 
       return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
    func configure( viewModel: MovieListCellViewModel, collectionView: UICollectionView, indexPath: IndexPath) {
//        self.idLabel.text = "\(viewModel.identity)"
        viewModel.title
            .bind(to: self.titleLabel.rx.text )
            .disposed(by: self.disposeBag)
        
        viewModel.popularity
            .map({"Popularity: \($0)"})
            .bind(to: self.popularityLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        viewModel.image
            .subscribe(onNext: {[weak self] (state:ImageState) in
                guard let strongSelf = self else {return}
               
                switch state {
                case .none:
                    strongSelf.displayNoImage(true)
                case .completed(let imageOrNil):
                    if let image = imageOrNil {
                        strongSelf.displayNoImage(false)
                    } else {
                        strongSelf.displayNoImage(true)
                    }
                case .loading:
                    strongSelf.displayNoImage(false)
                    break
                case .error(_):
                    strongSelf.displayNoImage(true)
                }
                strongSelf.backdropImageView.setState(state)
            })
            .disposed(by: self.disposeBag)
        
//        viewModel.booked
//            .map({!$0})
//            .bind(to: self.bookedLabel.rx.isHidden)
//            .disposed(by: self.disposeBag)
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
    }
    
    func displayNoImage(_ display: Bool) {
        if display {

            self.contentView.addSubview(self.noImageLabel)
            self.noImageLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addConstraint(self.noImageLabel.topAnchor.constraint(equalTo: self.backdropImageView.topAnchor))
            self.contentView.addConstraint(self.noImageLabel.leftAnchor.constraint(equalTo: self.backdropImageView.leftAnchor))
            self.contentView.addConstraint(self.noImageLabel.rightAnchor.constraint(equalTo: self.backdropImageView.rightAnchor))
            self.contentView.addConstraint(self.noImageLabel.bottomAnchor.constraint(equalTo: self.backdropImageView.bottomAnchor))
        } else {
            self.noImageLabel.removeFromSuperview()
        }
    }
    
}
