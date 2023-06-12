//
//  LoadingImage.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/05/2023.
//

import UIKit
import SystemConfiguration

class LoadingImage: UIImageView {
    
    private let spinner = UIActivityIndicatorView()
    private static let imageCache = NSCache<NSURL, UIImage>()
    
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
        contentMode = .scaleAspectFill
    }
    
    func loadImageURL(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                return
            }
            
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                LoadingImage.imageCache.setObject(image, forKey: url as NSURL)
                self?.spinner.stopAnimating()
            }
        }.resume()
        
    }
    
    /// Load image into ImageView
    /// - Parameter image: Image to be put in imageView
    func loadImage(from image: UIImage) {
        if image.size.width == 0{
            DispatchQueue.main.async {
                UIImage(systemName: "person.crop.square")
            }
        }else{
            DispatchQueue.main.async {
                self.image = image
                self.spinner.stopAnimating()
            }
        }
        
    }
}
