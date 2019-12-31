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
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    let noImageLabel = UILabel()
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.cornerRadius = 7
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.borderWidth = 1
        noImageLabel.text = "No Image"
        noImageLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        noImageLabel.textColor = UIColor.gray
        noImageLabel.textAlignment = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backdropImageView.image = nil
        titleLabel.text = ""
        popularityLabel.text = ""
        self.noImageLabel.removeFromSuperview()
        disposeBag = DisposeBag()
    }
    
    static func cellWith( collectionView: UICollectionView, indexPath: IndexPath ) -> Self {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Self.self), for: indexPath) as! Self
        return cell
    }
    
    // 寬固定，延展高
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.frame.size.height = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        return layoutAttributes
    }
    
    func configure( viewModel: MovieListCellViewModel, collectionView: UICollectionView, indexPath: IndexPath) {
        self.idLabel.text = "\(viewModel.identity)"
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
                strongSelf.backdropImageView.setState(state)
                if let size = strongSelf.backdropImageView.image?.size {
                    let factor = strongSelf.backdropImageView.frame.size.width / size.width 
                    strongSelf.imageViewHeightConstraint.constant = size.height * factor
                }
                strongSelf.setNeedsUpdateConstraints()
                strongSelf.setNeedsLayout()
            })
            .disposed(by: self.disposeBag)
        
        viewModel.booked
            .map({!$0})
            .bind(to: self.bookedLabel.rx.isHidden)
            .disposed(by: self.disposeBag)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if self.backdropImageView.image == nil {
            self.contentView.addSubview(self.noImageLabel)
            self.noImageLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addConstraint( NSLayoutConstraint(item: self.noImageLabel, attribute: NSLayoutConstraint.Attribute.leading,  relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.backdropImageView, attribute: NSLayoutConstraint.Attribute.leading,  multiplier: 1.0, constant: 0) )
            self.contentView.addConstraint( NSLayoutConstraint(item: self.noImageLabel, attribute: NSLayoutConstraint.Attribute.top,      relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.backdropImageView, attribute: NSLayoutConstraint.Attribute.top,      multiplier: 1.0, constant: 0) )
            self.contentView.addConstraint( NSLayoutConstraint(item: self.noImageLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.backdropImageView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0) )
            self.contentView.addConstraint( NSLayoutConstraint(item: self.noImageLabel, attribute: NSLayoutConstraint.Attribute.bottom,   relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.backdropImageView, attribute: NSLayoutConstraint.Attribute.bottom,   multiplier: 1.0, constant: 0) )
            self.imageViewHeightConstraint.constant = 200
        } else {
            self.noImageLabel.removeFromSuperview()
            
        }
    }

}
