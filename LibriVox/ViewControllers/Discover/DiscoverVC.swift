//
//  DiscoverRealVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 06/04/2023.
//

import UIKit

protocol DiscoverRealDelegate: AnyObject {
    func didChangeSearchText(_ text: String)
}

class DiscoverVC: UIViewController {
    
    @IBOutlet weak var container: UIView!
   // @IBOutlet weak var img: UIImageView!
    
    var emptyStateVC: DiscoverOptionsVC?
    var resultsVC: ResultBooksVC?
    
    
    @IBAction func searchHandler(_ sender: UITextField) {
        if let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty {
            resultsVC?.didChangeSearchText(searchText)
            addViewController(resultsVC!, container, emptyStateVC)
            
        } else {
            addViewController(emptyStateVC!,container,resultsVC)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*if let image = generateBookCoverImage()?.image {
            img.image = image
        }*/
        
        emptyStateVC = storyboard?.instantiateViewController(withIdentifier: "EmptyStateViewController") as? DiscoverOptionsVC
        resultsVC = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as? ResultBooksVC
        
        addChild(emptyStateVC!)
        container.addSubview(emptyStateVC!.view)
        emptyStateVC!.view.frame = container.bounds
        emptyStateVC!.didMove(toParent: self)
    }
    
    func addViewController(_ childViewController: UIViewController, _ container: UIView, _ stateViewController: UIViewController?) {
        
        addChild(childViewController)
        container.addSubview(childViewController.view)
        childViewController.view.frame = container.bounds
        childViewController.didMove(toParent: self)
        
        if let stateVC = stateViewController, stateVC.parent != nil {
            stateVC.willMove(toParent: nil)
            stateVC.view.removeFromSuperview()
            stateVC.removeFromParent()
        }
    }
    
    /*func generateBookCoverImage() -> UIImageView? {
        let title = "Lorem.title"
        let author = "Lorem.fullName"
        
        // Create a view to display the book cover
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 900))
        view.backgroundColor = .clear  // Set background color to clear
        
        let coverView = UIView(frame: CGRect(x: 50, y: 50, width: 500, height: 800))
        coverView.backgroundColor = .white
        view.addSubview(coverView)
        
        let titleLabel = UILabel(frame: CGRect(x: 50, y: 200, width: 500, height: 200))
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 40)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        coverView.addSubview(titleLabel)
        
        let authorLabel = UILabel(frame: CGRect(x: 50, y: 500, width: 500, height: 200))
        authorLabel.text = "by " + author
        authorLabel.font = UIFont.systemFont(ofSize: 30)
        authorLabel.numberOfLines = 0
        authorLabel.textAlignment = .center
        coverView.addSubview(authorLabel)
        
        // Add random patterns to the cover view
        for _ in 1...10 {
            let pattern = UIView(frame: CGRect(x: CGFloat.random(in: 0...coverView.frame.width), y: CGFloat.random(in: 0...coverView.frame.height), width: CGFloat.random(in: 100...300), height: CGFloat.random(in: 100...300)))
            pattern.backgroundColor = UIColor(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0.2...1), brightness: CGFloat.random(in: 0.5...1), alpha: 0.3)
            pattern.layer.cornerRadius = CGFloat.random(in: 0...min(pattern.frame.width, pattern.frame.height) / 2)
            pattern.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: 0...CGFloat.pi * 2))
            coverView.addSubview(pattern)
        }
        
        // Take a screenshot of the view
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { (context) in
            view.layer.render(in: context.cgContext)
        }
        
        // Create an UIImageView and set the generated image as its image
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }*/


}
