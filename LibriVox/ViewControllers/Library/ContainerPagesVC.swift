//
//  ContainerPagesVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 23/03/2023.
//

import UIKit


class ContainerPagesVC: UIPageViewController {
    var indexPage = 0
    var pages: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Library", bundle: nil)
        
        let readingVC = storyboard?.instantiateViewController(withIdentifier: "ReadingVC") as! ReadingVC
        let toStartVC = storyboard?.instantiateViewController(withIdentifier: "ToStartVC") as! FavoritesVC
        let finishedVC = storyboard?.instantiateViewController(withIdentifier: "FinishedVC") as! FinishedCVC
        pages = [readingVC, toStartVC, finishedVC]
        
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }
    
    func gotoPage(pageNumber: Int){
        indexPage = pageNumber
        
        if indexPage < 0 { indexPage = 0 }
        if indexPage > 2 { indexPage = 2 }
        
        
        setViewControllers([pages[indexPage]], direction: .forward, animated: false, completion: nil)
    }
}

