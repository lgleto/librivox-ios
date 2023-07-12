//
//  HomepageTBC.swift
//  LibriVox
//
//  Created by Leandro Silva on 24/03/2023.
//

import UIKit
import SwaggerClient

class HomepageTBC: UITabBarController {
    
    var miniPlayer: MiniPlayerVC?
    var containerView: UIView?
    private var tabBarHiddenContext = 0
    var isHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addChildView(book: PlayableItemProtocol) {
        let newContainerView = UIView()
        newContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newContainerView)
        
        if let existingMiniPlayer = miniPlayer {
            existingMiniPlayer.removeFromParent()
            existingMiniPlayer.view.removeFromSuperview()
        }
        
        miniPlayer = MiniPlayerVC()
        miniPlayer!.delegate = self
        miniPlayer!.book = getBookByIdCD(id: book._id!)
        miniPlayer!.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(miniPlayer!)
        newContainerView.addSubview(miniPlayer!.view)
        miniPlayer?.didMove(toParent: self)
        
        if let childIndex = viewControllers?.firstIndex(of: miniPlayer!) {
            viewControllers?.remove(at: childIndex)
        }
        
        containerView = newContainerView
        setConstraints()
        playerHandler.book = book
        playerHandler.playPause()
        newContainerView.alpha = 0.0
        newContainerView.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0.0)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            newContainerView.alpha = 1.0
            newContainerView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        
    }
    
    func setConstraints() {
        if let containerView = containerView {
            containerView.removeConstraints(containerView.constraints)
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 78),
                containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
                
                miniPlayer!.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                miniPlayer!.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                miniPlayer!.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                miniPlayer!.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
        }
    }
    
}

extension HomepageTBC: MiniPlayerDelegate {
    func closeMiniPlayer() {
        containerView!.alpha = 1.0
        containerView!.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
        
        let translationX = view.bounds.width + containerView!.frame.size.width
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.containerView!.transform = CGAffineTransform(translationX: translationX, y: 0.0)
            self.containerView!.alpha = 0.0
        }, completion: {_ in
            self.containerView!.removeFromSuperview()
            self.containerView = nil
        })
        
    }
    func presentPlayerView(audiobook: PlayableItemProtocol) {
        goToPlayer(book: audiobook, parentVC: self)
    }
}

