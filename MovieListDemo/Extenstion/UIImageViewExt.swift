//
//  UIImageViewExt.swift
//  MovieListDemo
//
//  Created by GevinChen on 2020/1/1.
//  Copyright © 2020 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImageView {
    
    // MARK: - loading
    
    struct AssociatedKeys {
//        static var isLoadingKey: UInt8 = 0
//        static var loadingViewKey: UInt8 = 0
        static var stateKey: UInt8 = 0
    }
    
//    var isLoading: Bool {
//        get {
//            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.isLoadingKey) as? Bool else { return false }
//            return value
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.isLoadingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            if newValue {
//                self.loadingView.isHidden = false
//                self.loadingView.startAnimating()
//            } else {
//                self.loadingView.isHidden = true
//                self.loadingView.stopAnimating()
//            }
//        }
//    }
//    
//    var loadingView: UIActivityIndicatorView {
//        get {
//            if let value = objc_getAssociatedObject(self, &AssociatedKeys.loadingViewKey) as? UIActivityIndicatorView {
//                return value
//            } else {
//                let view = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
//                objc_setAssociatedObject(self, &AssociatedKeys.loadingViewKey, view, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                self.addSubview(view)
//                view.translatesAutoresizingMaskIntoConstraints = false
//                self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
//                self.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
//                view.isHidden = true
//                view.stopAnimating()
//                return view
//            }
//        }
//        set {
//            if let value = objc_getAssociatedObject(self, &AssociatedKeys.loadingViewKey) as? UIActivityIndicatorView {
//                value.stopAnimating()
//                value.removeFromSuperview()
//            }
//            
//            objc_setAssociatedObject(self, &AssociatedKeys.loadingViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            self.addSubview(newValue)
//            newValue.translatesAutoresizingMaskIntoConstraints = false
//            self.addConstraint(NSLayoutConstraint(item: newValue, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
//            self.addConstraint(NSLayoutConstraint(item: newValue, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
//            newValue.isHidden = true
//            newValue.stopAnimating()
//        }
//    }
    
    var state: ImageState {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.stateKey) as? ImageState else { return ImageState.none }
            return value
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.stateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.setState(newValue)
        }
    }
    
    func setState(_ state: ImageState ) {
        switch state {
        case .completed(image: let image ):
            self.image = image
//            self.isLoading = false
        case .loading:
            self.image = nil
//            self.isLoading = true
            break
        case .error(error: _):
            self.image = nil
            break
        case .none:
            self.image = nil
//            self.isLoading = false
            break
        }
    }
    
}

extension Reactive where Base: UIImageView {

    var state: Binder<ImageState> {
        return Binder(self.base) { control, value in
            control.setState(value)
        }
    }
    
}

