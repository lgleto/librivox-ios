//
//  RoundedBookImageView.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 20/03/2023.
//

import Foundation
import UIKit

@IBDesignable
class RoundedBookImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
}
