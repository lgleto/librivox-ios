//
//  LoadingImage.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/05/2023.
//

import UIKit

class LoadingImage: UIImageView {
    private let spinner = UIActivityIndicatorView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        spinner.startAnimating()
        
        
        spinner.isHidden = false
        spinner.hidesWhenStopped = true
        
        self.backgroundColor = .systemGray6
        contentMode = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                self.spinner.stopAnimating()
                return
            }
            
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                self?.contentMode = .scaleAspectFill
                self?.spinner.stopAnimating()
            }
        }.resume()
    }
    
    func loadImage(from image: UIImage) {
            self.image = image
            self.contentMode = .scaleAspectFit
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.spinner.stopAnimating()
            }
    }
}
