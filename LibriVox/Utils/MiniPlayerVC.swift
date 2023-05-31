//
//  MiniPlayerVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 29/05/2023.
//

import UIKit

protocol MiniPlayerDelegate {
    func presentPlayerView()
    func closeMiniPlayer()
    func showMiniPlayer()
}

protocol ShowMiniPlayerDelegate{
    func showMiniPlayer()
}
class MiniPlayerVC: UIViewController {
    
    var delegate: MiniPlayerDelegate?
    
    let backgroundImg: BlurredImageView = {
        let theImageView = BlurredImageView()
        theImageView.image = UIImage(named: "28187")
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        return theImageView
    }()
    
    let playBtn: ToggleBtn = {
        let btn = ToggleBtn()
        btn.imgSelected = UIImage(named: "play-button")
        btn.imgNotSelected = UIImage(named: "pause-button")
        btn.isSelected = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let booksImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "28187")
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    lazy var titleBook: UILabel = {
        let label = UILabel()
        label.text = "Percy Jackson and the Lightining Thief "
        label.font = UIFont(name: "Nunito-Regular", size: 15)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var author: UILabel = {
        let label = UILabel()
        label.text = "Rick Riordan"
        label.font = UIFont(name: "Nunito-Light", size: 13)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let closeBtn: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "close")
        btn.setImage(img , for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("Width occupied by titleBook label: \(titleBook.intrinsicContentSize.width)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.insertSubview(backgroundImg, at: 0)
        
        backgroundImg.layer.cornerRadius = 10
        backgroundImg.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            backgroundImg.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImg.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backgroundImg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            backgroundImg.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
        
        view.insertSubview(booksImg, at: 1)
        
        booksImg.layer.cornerRadius = 10
        booksImg.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            booksImg.topAnchor.constraint(equalTo: view.topAnchor),
            booksImg.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            booksImg.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            booksImg.widthAnchor.constraint(equalToConstant: 90)
        ])
        
        view.insertSubview(titleBook, at: 2)
        NSLayoutConstraint.activate([
            titleBook.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
            titleBook.leadingAnchor.constraint(equalTo: booksImg.trailingAnchor, constant: 20),
            titleBook.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60)
        ])
        
        view.insertSubview(author, at: 3)
        NSLayoutConstraint.activate([
            author.topAnchor.constraint(equalTo: titleBook.bottomAnchor),
            author.leadingAnchor.constraint(equalTo: booksImg.trailingAnchor, constant: 20),
            author.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60 )
        ])
        
        view.insertSubview(playBtn, at: 4)
        NSLayoutConstraint.activate([
            playBtn.centerXAnchor.constraint(equalTo: booksImg.centerXAnchor, constant: 3),
            playBtn.centerYAnchor.constraint(equalTo: booksImg.centerYAnchor),
            playBtn.widthAnchor.constraint(equalToConstant: 30),
            playBtn.heightAnchor.constraint(equalToConstant: 30)
            
        ])
        
        view.insertSubview(closeBtn, at: 5)
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: titleBook.topAnchor),
            closeBtn.widthAnchor.constraint(equalToConstant: 12),
            closeBtn.heightAnchor.constraint(equalToConstant: 12),
            closeBtn.trailingAnchor.constraint(equalTo: backgroundImg.trailingAnchor, constant: -12)
        ])
        
       /* let tap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true*/
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(closeTap))
        closeBtn.addGestureRecognizer(closeTap)
        closeBtn.isUserInteractionEnabled = true

        playBtn.isUserInteractionEnabled = true

    }
    
    @objc func tapDetected() {
        guard let delegate = delegate else { return }
        delegate.presentPlayerView()
    }
    
    @objc func closeTap() {
        guard let delegate = delegate else { return }
        delegate.closeMiniPlayer()
    }



}
