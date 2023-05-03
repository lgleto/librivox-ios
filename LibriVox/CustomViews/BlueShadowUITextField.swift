//
//  BlueShadowUITextField.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 01/05/2023.
//

import Foundation
import UIKit

@IBDesignable
class BlueShadowUITextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    private let shadowOffset = CGSize(width: 4, height: 4)
    private let shadowRadius: CGFloat = 0
    
    private func setupView() {
        backgroundColor = fillColor
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
    }
}
