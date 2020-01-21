//
//  MovieDetailController.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/27.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class MovieDetailController: UIViewController, ViewType {

    var viewModel: MovieDetailViewModelType?
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bookButton: UIButton!
    
    lazy var noImageLabel: UILabel = { 
        let label = UILabel()
        label.text = "No Image"
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        return label
    }() 
    
    deinit {
        print("MovieDetailController dealloc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindUI()
        self.viewModel?.initial()
    }
    
    func bindUI() {
        self.viewModel?.image
            .do(onNext: {[weak self] (state:ImageState) in
                guard let strongSelf = self else { return }
                if case let .completed( imageOrNil ) = state {
                    if let image = imageOrNil {
                        let factor = UIScreen.main.bounds.size.width / image.size.width
                        strongSelf.imageViewHeightConstraint.constant = image.size.height * factor
                        strongSelf.hideNoImage()
                    } else {
                        strongSelf.imageViewHeightConstraint.constant = 235
                        strongSelf.displayNoImage()
                    }
                }
            })
            .drive(self.movieImageView.rx.state)
            .disposed(by: self.disposeBag)
        
        self.viewModel?.isBooked.asObservable()
            .subscribe(onNext: {[weak self] (booked:Bool) in
                guard let strongSelf = self else { return }
                strongSelf.bookButtonConfig(booked: booked)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel?.synopsis
            .map({ $0.count > 0 ? $0 : "None"})
            .drive(self.synopsisLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        self.viewModel?.genres
            .map({ $0.count > 0 ? $0 : "None"})
            .drive(self.genresLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        self.viewModel?.language
            .map({ $0.count > 0 ? $0 : "None"})
            .drive(self.languageLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        self.viewModel?.duration
            .map({"\(Int($0/60))h \(Int($0 % 60))m"})
            .drive(self.durationLabel.rx.text)
            .disposed(by: self.disposeBag)
        
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
        
        self.bookButton
            .rx
            .tap
            .throttle( 1, scheduler: MainScheduler.instance)
            .subscribe {[weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.viewModel?.bookMovie()
            }
            .disposed(by: self.disposeBag)
    }
    
    func bookButtonConfig( booked: Bool ) {
        let color = UIColor.init(red: 94.0/255.0, green: 171.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        if booked {
            self.bookButton.layer.cornerRadius = 7
            self.bookButton.layer.borderWidth = 0
            self.bookButton.backgroundColor = color
            self.bookButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.bookButton.setTitle("Booked", for: UIControl.State.normal)
        } else {
            self.bookButton.layer.cornerRadius = 7
            self.bookButton.layer.borderWidth = 1
            self.bookButton.layer.borderColor = color.cgColor
            self.bookButton.backgroundColor = UIColor.white
            self.bookButton.setTitleColor( color, for: UIControl.State.normal)
            self.bookButton.setTitle("Book", for: UIControl.State.normal)
        }
    }
    
    func displayNoImage() {
        self.scrollView.addSubview( self.noImageLabel )
        self.noImageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addConstraint( NSLayoutConstraint(item: self.noImageLabel, attribute: NSLayoutConstraint.Attribute.leading,  relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.movieImageView, attribute: NSLayoutConstraint.Attribute.leading,  multiplier: 1.0, constant: 0) )
        self.scrollView.addConstraint( NSLayoutConstraint(item: self.noImageLabel, attribute: NSLayoutConstraint.Attribute.top,      relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.movieImageView, attribute: NSLayoutConstraint.Attribute.top,      multiplier: 1.0, constant: 0) )
        self.scrollView.addConstraint( NSLayoutConstraint(item: self.noImageLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.movieImageView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0) )
        self.scrollView.addConstraint( NSLayoutConstraint(item: self.noImageLabel, attribute: NSLayoutConstraint.Attribute.bottom,   relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.movieImageView, attribute: NSLayoutConstraint.Attribute.bottom,   multiplier: 1.0, constant: 0) )
        self.scrollView.layoutIfNeeded()
    }
    
    func hideNoImage() {
        self.noImageLabel.removeFromSuperview()
        self.scrollView.layoutIfNeeded()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
