//
//  LoadingImage.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/05/2023.
//

import UIKit
import SystemConfiguration

func isNetworkReachable() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return isReachable && !needsConnection
}

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
        DispatchQueue.main.async {
            self.image = image
            self.spinner.stopAnimating()
        }
    }
}


