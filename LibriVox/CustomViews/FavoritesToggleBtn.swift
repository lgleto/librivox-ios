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
    
    let selectedColor = UIColor.systemYellow
    let normalColor = UIColor.systemGray4
    let img = UIImage(systemName: "star.square.fill")
    
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
        setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25), forImageIn: .normal)
        
        if isSelected {
            let selectedImage = img?.withTintColor(selectedColor).withRenderingMode(.alwaysOriginal)
            setImage(selectedImage, for: .normal)
           
        } else {
            let normalImage = img?.withTintColor(normalColor).withRenderingMode(.alwaysOriginal)
            setImage(normalImage, for: .normal)
            
        }
    }
}
