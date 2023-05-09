//
//  CircularImageView.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 20/03/2023.
//

import Foundation
import UIKit

@IBDesignable
class CircularImageView: LoadingImage {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
