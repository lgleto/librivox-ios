//
//  MiniPlayerVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 29/05/2023.
//

import UIKit
import SwaggerClient

protocol MiniPlayerDelegate {
    func presentPlayerView()
    func closeMiniPlayer()
}

class MiniPlayerManager {
    static let shared = MiniPlayerManager()

    var currentAudiobookID: String?
    //var isPlaying: Bool = true

    private init() {}
}


class MiniPlayerVC: UIViewController {
    
    var delegate: MiniPlayerDelegate?
    
    let backgroundImg: BlurredImageView = {
        let theImageView = BlurredImageView()
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        return theImageView
    }()
    
    let playBtn: ToggleBtn = {
        let btn = ToggleBtn()
        btn.imgSelected = UIImage(named: "pause-button")
        btn.imgNotSelected = UIImage(named: "play-button")
        btn.isSelected = true
        btn.isUserInteractionEnabled = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(playBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    let booksImg: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    lazy var titleBook: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Nunito-Regular", size: 15)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var author: UILabel = {
        let label = UILabel()
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
    
    var book: AudioBooks_Data? {
        didSet {
            updateUI()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        setViews()
    }
    
    func setViews(){
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
    }
    
    func updateUI() {
        guard let book = book else {
            return
        }
        
        MiniPlayerManager.shared.currentAudiobookID = book.id
        
        titleBook.text = book.title
        author.text = book.authors
        getCoverBook(id: book.id!) { img in
            if let img = img {
                self.booksImg.image = img
                self.backgroundImg.loadImage(from: img)
            }
        }
    }
    
    @objc func playBtnClicked() {
        playBtn.isSelected = !playBtn.isSelected
        NotificationCenter.default.post(name: Notification.Name("miniPlayerState"), object: nil, userInfo: ["state": playBtn.isSelected])

    }

    
    @objc func tapDetected() {
        guard let delegate = delegate else { return }
        delegate.presentPlayerView()
    }
    
    @objc func closeTap() {
        guard let delegate = delegate else { return }
        NotificationCenter.default.post(name: Notification.Name("miniPlayerState"), object: nil, userInfo: ["state": playBtn.isSelected])
        delegate.closeMiniPlayer()
    }
}
