//
//  ToggleBtn.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 14/05/2023.
//

import UIKit

class ToggleBtn: UIButton {
    
    @IBInspectable var imgNotSelected: UIImage?
    @IBInspectable var imgSelected: UIImage?
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateAppearance()
        addTarget(self, action: #selector(btnClicked(_:)), for: .touchUpInside)
    }
    
    @objc func btnClicked(_ sender: UIButton) {
        isSelected.toggle()
    }
    
    func updateAppearance() {
        setImage(isSelected ? imgSelected : imgNotSelected, for: .normal)
    }
}
