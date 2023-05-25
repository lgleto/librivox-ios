//
//  LaunchScreenVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 24/05/2023.
//

import UIKit
import FirebaseAuth

class LaunchScreenVC: UIViewController {
    
    var isLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isLoggedIn = (Auth.auth().currentUser != nil)
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(true)
        createAnimation()
        
    }
    private func createAnimation() {
        let circleSize = UIScreen.main.bounds.width
        
        let circle = CALayer()
        circle.bounds = CGRect(x: 0, y: 0, width: circleSize, height: circleSize)
        circle.position = view.center
        circle.cornerRadius = circleSize / 2
        if let lightBlueTone = UIColor(named: "Lighter Blue Tone") {
            circle.backgroundColor = lightBlueTone.cgColor
        }
        
        view.layer.insertSublayer(circle, at: 0)

        let animation = CABasicAnimation(keyPath: "bounds")
        animation.fromValue = NSValue(cgRect: circle.bounds)
        animation.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2))
        animation.duration = 2.0
        //animation.timingFunction = CAMediaTimingFunction(name: .easeIn)

        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false // Prevent the animation from being removed

        circle.add(animation, forKey: "boundsAnimation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animation.duration) {
            let storyboardName = self.isLoggedIn ? "HomePage" : "LoginRegister"
            let viewControllerIdentifier = self.isLoggedIn ? "HomepageTBC" : "LoginId"

            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            
            if let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? UIViewController {
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
}
