//
//  ImageCache.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 09/05/2023.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                completion(nil)
                return
            }
            
            self?.cache.setObject(image, forKey: url as NSURL)
            completion(image)
        }.resume()
    }
}
