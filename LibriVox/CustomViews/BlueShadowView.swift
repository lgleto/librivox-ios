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
    private let fillColor: UIColor = UIColor(red: 252.0, green: 252.0, blue: 252.0, alpha: 1.0)
    private let shadowColor: UIColor = UIColor(named: "Main Blue Tone")!
    private let shadowOpacity: Float = 0.5
    private let shadowOffset = CGSize(width: 7, height: 7)
    private let shadowRadius: CGFloat = 0
    
    private func setupView() {
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = shadowOffset
            shadowLayer.shadowOpacity = shadowOpacity
            shadowLayer.shadowRadius = shadowRadius
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
        
    }
}
