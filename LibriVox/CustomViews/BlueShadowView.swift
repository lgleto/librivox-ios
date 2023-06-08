//
//  BlueShadowView.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 21/03/2023.
//

import Foundation
import UIKit

@IBDesignable
class BlueShadowView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.backgroundColor = UIColor.clear.cgColor
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private var shadowLayer: CAShapeLayer!
        private let cornerRadius: CGFloat = 10
        private let fillColor: UIColor = UIColor(named: "Blue Shadow Background")!
        private let shadowColor: UIColor = UIColor(named: "Blue Shadow")!
        private let shadowOpacity: Float = 1
        private let shadowOffset = CGSize(width: 7, height: 7)
        private let shadowRadius: CGFloat = 0
    
    private func setupView() {
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.fillColor = fillColor.cgColor
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowOffset = shadowOffset
            shadowLayer.shadowOpacity = shadowOpacity
            shadowLayer.shadowRadius = shadowRadius
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update the path of the shadow layer to match the current frame
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}
