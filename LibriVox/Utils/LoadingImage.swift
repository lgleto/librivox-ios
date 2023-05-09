//
//  LoadingImage.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/05/2023.
//

import UIKit

class LoadingImage: UIImageView {
    
    private let cache = NSCache<NSURL, UIImage>()
    
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
    
    func loadImage(from url: URL) {
        if let cachedImage = LoadingImage.imageCache.object(forKey: url as NSURL) {
            print("iupiii it's on cache :D")
            DispatchQueue.main.async() {
                self.image = cachedImage
                self.spinner.stopAnimating()
            }
            return
        }

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

    
    func loadImage(from image: UIImage) {
            self.image = image
            self.spinner.stopAnimating()
        
    }
}