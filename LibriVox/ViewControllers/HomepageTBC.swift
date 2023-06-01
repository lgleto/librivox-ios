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
    
    func addChildView(book: Audiobook) {
        let newContainerView = UIView()
        newContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newContainerView)
        
        if let existingMiniPlayer = miniPlayer {
            existingMiniPlayer.removeFromParent()
            existingMiniPlayer.view.removeFromSuperview()
        }
        
        miniPlayer = MiniPlayerVC()
        miniPlayer!.delegate = self
        miniPlayer!.book = book
        miniPlayer!.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(miniPlayer!)
        newContainerView.addSubview(miniPlayer!.view)
        miniPlayer?.didMove(toParent: self)
        
        if let childIndex = viewControllers?.firstIndex(of: miniPlayer!) {
            viewControllers?.remove(at: childIndex)
        }
        
        containerView = newContainerView
        setConstraints()
    
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
            
            let bottomConstraint: NSLayoutConstraint
           
            if isHidden == true {
                bottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
              //  print("ta")
            } else {
                // Tab bar is visible
                bottomConstraint = containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
                //print("nao ta")
            }
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                containerView.heightAnchor.constraint(equalToConstant: 78),
                bottomConstraint,
                
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
        func presentPlayerView() {
            /*let vc = PlayerVC2()
             vc.modalPresentationStyle = .fullScreen
             present(vc, animated: true)*/
        }
    }

