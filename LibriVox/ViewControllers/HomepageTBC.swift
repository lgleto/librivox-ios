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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addChildView(book: Audiobook) {
        let newContainerView = UIView()
        newContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newContainerView)
        
        if let existingMiniPlayer = miniPlayer {
             existingMiniPlayer.removeFromParent()
             existingMiniPlayer.view.removeFromSuperview()
         }
        
        miniPlayer = MiniPlayerVC() // Instantiate MiniPlayerVC
        miniPlayer!.view.translatesAutoresizingMaskIntoConstraints = false
        miniPlayer!.delegate = self
        miniPlayer!.book = book
        
        addChild(miniPlayer!)
        newContainerView.addSubview(miniPlayer!.view)
        miniPlayer?.didMove(toParent: self)
        
        if let childIndex = viewControllers?.firstIndex(of: miniPlayer!) {
            viewControllers?.remove(at: childIndex)
        }
        
        containerView = newContainerView // Update the reference to containerView
        setConstraints()
        
    }
    
    func setConstraints() {
        let g = view.safeAreaLayoutGuide
        if let containerView = containerView{
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 78),
                
                miniPlayer!.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                miniPlayer!.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                miniPlayer!.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                miniPlayer!.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
        }}
}

extension HomepageTBC: MiniPlayerDelegate, ShowMiniPlayerDelegate {
    func showMiniPlayer(book: Audiobook) {
        addChildView(book: book)
    }
    
    func closeMiniPlayer() {
        UIView.animate(withDuration: 0.2, animations: {self.containerView!.alpha = 0.0},
                       completion: {(value: Bool) in
            self.containerView!.removeFromSuperview()
            self.containerView = nil
        })
    }
    
    func presentPlayerView() {
        /*let vc = PlayerVC2()
         vc.modalPresentationStyle = .fullScreen
         present(vc, animated: true)*/
    }
}
