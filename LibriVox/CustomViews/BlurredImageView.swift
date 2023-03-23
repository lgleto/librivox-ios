//
//  BlurredImageView.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 20/03/2023.
//

import Foundation
import UIKit
import CoreImage

@IBDesignable
class BlurredImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}


