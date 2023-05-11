//
//  PlayToggleBtn.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 11/05/2023.
//

import UIKit

class PlayToggleBtn: UIButton {
    
    let imgNotSelected = UIImage(named: "play")
    let imgSelected = UIImage(named: "pause")
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


