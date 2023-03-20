//
//  RoundView.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 20/03/2023.
//

import Foundation
import UIKit

@IBDesignable
class RoundView: UIView {
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
