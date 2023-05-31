//
//  PlayerVC2.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 29/05/2023.
//

import UIKit

class PlayerVC2: UIViewController {

    var dismissButton: UIButton = {
           let button = UIButton()
           button.translatesAutoresizingMaskIntoConstraints = false
           button.setTitle("Dismiss", for: .normal)
           button.tintColor = .white
           button.backgroundColor = .red
           button.layer.cornerRadius = 8
           button.clipsToBounds = true
           button.titleEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
           button.addTarget(self, action: #selector(dismissBTTapped), for: .touchUpInside)
           return button
       }()

       override func viewDidLoad() {
           super.viewDidLoad()

           view.backgroundColor = .green
           view.addSubview(dismissButton)
        
           dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
           dismissButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
           dismissButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.26).isActive = true
       }
       
       @objc func dismissBTTapped(_ sender: Any) {
           self.dismiss(animated: true)
       }
}
