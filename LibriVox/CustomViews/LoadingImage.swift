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
        
        contentMode = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let alertImage = UIImage(systemName: "red-alert")
                    self.image = alertImage
                    self.contentMode = .center
                    self.spinner.stopAnimating()
                }
                return }
            
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                self?.contentMode = .scaleAspectFill
                self?.spinner.stopAnimating()
            }
        }.resume()
        
    }
}
