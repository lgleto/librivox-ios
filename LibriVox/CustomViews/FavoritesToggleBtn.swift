//
//  FavoritesToggleBtn.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 21/04/2023.
//

import Foundation
import UIKit

@IBDesignable
class FavoritesToggleBtn: UIButton {

    let imgNotSelected = UIImage(named: "star")
    let imgSelected = UIImage(named: "starOn")
    private var _isSelected = false
    
    override var isSelected: Bool {
        get {
            return _isSelected
        }
        set {
            _isSelected = newValue
            updateAppearance()
        }
    }
    
    override func awakeFromNib() {
        updateAppearance()
        self.addTarget(self, action: #selector(btnClicked(_:)),
                       for: .touchUpInside)
    }
    
    @objc func btnClicked (_ sender:UIButton) {
        isSelected.toggle()
    }
    
    func updateAppearance() {
        isSelected ? setImage(imgSelected, for: .normal) :  setImage(imgNotSelected, for: .normal)
    }
}
