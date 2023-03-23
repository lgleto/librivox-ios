//
//  ContainerPagesVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 23/03/2023.
//

import UIKit


//TODO: Change the animation
class ContainerPagesVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var indexPage = 0
    var pages: [UIViewController] = []
    
    var didMove : ((Int)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Library", bundle: nil)
        
        
        let readingVC = storyboard?.instantiateViewController(withIdentifier: "ReadingVC") as! UIViewController
        let toStartVC = storyboard?.instantiateViewController(withIdentifier: "ToStartVC") as! UIViewController
        let finishedVC = storyboard?.instantiateViewController(withIdentifier: "FinishedVC") as! UIViewController
        pages = [readingVC, toStartVC, finishedVC]
        
        self.delegate = self
        self.dataSource = self
        
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }
    
    
    func gotoPage(pageNumber: Int){
        indexPage = pageNumber
        
        if indexPage < 0 { indexPage = 0 }
        if indexPage > 2 { indexPage = 2 }
        
        
        setViewControllers([pages[indexPage]], direction: .forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        indexPage = pages.firstIndex(of: viewController) ?? NSNotFound
        
        if (indexPage == NSNotFound) || (indexPage == 0) {return nil}
        
        indexPage -= 1
        
        if let page = didMove {page(indexPage)}
        
        return pages[indexPage]
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        indexPage = pages.firstIndex(of: viewController) ?? NSNotFound
        
        if (indexPage == NSNotFound) || (indexPage + 1 >= pages.count) {
            return nil
        }
        
        indexPage += 1
        
        if let page = didMove {
            page(indexPage)
        }
        
        return pages[indexPage]
    }
}
