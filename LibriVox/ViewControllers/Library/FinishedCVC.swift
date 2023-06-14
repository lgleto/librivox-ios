//
//  FinishedCVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 27/04/2023.
//

import UIKit
import SwaggerClient
import FirebaseFirestore
import FirebaseAuth
import CoreData

class FinishedCVC: UICollectionViewController {
    
    var finalList: [Book] = []
    
    let spinner = UIActivityIndicatorView(style: .medium)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        collectionView.backgroundView = spinner
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //let bookEntity = BookCD(context: context)
        /*bookEntity.id = "1"
        bookEntity.isFav = true
        do{try context.save(); print("salvo")}catch{print("context save error")}*/
        
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "BookCD", in: context)
        
        getBooksByParameter("isFinished", value: true){ books in
            self.finalList = books
            self.spinner.stopAnimating()
            
            /*for book in books {
                let bookCD = BookCD(context: context)
                bookCD.id = book.book._id ?? "0"
                bookCD.isFinished = book.isFinished ?? false
                bookCD.isFav = book.isFav ?? false
                bookCD.isReading = book.isReading ?? false
                bookCD.sectionStopped = Int16(book.sectionStopped ?? 0)
                bookCD.timeStopped = Int16(book.timeStopped  ?? 0)
                
                let audioBookCD = AudioBookCD(context: context)
                audioBookCD.id = book.book._id ?? "0"
                audioBookCD.authors = displayAuthors(authors: book.book.authors ?? [])
                audioBookCD.descr = removeHtmlTagsFromText(text: book.book._description ?? "")
                audioBookCD.genres = displayGenres(strings: book.book.genres ?? [])
                audioBookCD.language = book.book.language ?? ""
                audioBookCD.numSections = book.book.numSections ?? ""
                audioBookCD.title = book.book.title ?? ""
                audioBookCD.totaltime = book.book.totaltime ?? ""
                audioBookCD.urlLibrivox = book.book.urlLibrivox ?? ""
                audioBookCD.urlProject = book.book.urlProject ?? ""
                audioBookCD.urlRss = book.book.urlRss ?? ""
                audioBookCD.urlZipFile = book.book.urlZipFile ?? ""
                
                if let sections = book.book.sections {
                    for section in sections {
                        let sectionCD = SectionCD(context: context)
                        sectionCD.id = section._id ?? "0"
                        sectionCD.fileName = section.fileName ?? ""
                        sectionCD.language = section.language ?? ""
                        sectionCD.listenUrl = section.listenUrl ?? ""
                        sectionCD.playtime = section.playtime ?? ""
                        sectionCD.sectionNumber = section.sectionNumber ?? ""
                        sectionCD.title = section.title ?? ""
                        
                        audioBookCD.sections = sectionCD
                    }
                }
                
                bookCD.audiobook = audioBookCD
                
                
                do{try context.save(); print("salvo")}catch{print("context save error")}
                */
                
                self.collectionView.reloadSections(IndexSet(integer: 0))
                checkAndUpdateEmptyState(list: self.finalList, alertImage: UIImage(named: "completedBook")!,view: self.collectionView, alertText: "No books finished yet")
            }
            
        }

        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return finalList.count
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListBooksCell", for: indexPath) as! ListBooksCell
            
            let book = finalList[indexPath.row].book
            cell.titleBook.text = book.title
            cell.imageBook.image = nil
             getCoverBook(id:book._id! ,url: book.urlLibrivox!){img in
             
             if let img = img{
             cell.imageBook.loadImage(from: img)
             }
             }
            
            return cell
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showDetailsBook", let indexPath = collectionView.indexPathsForSelectedItems?.first,
               let detailVC = segue.destination as? BookDetailsVC {
                let item = indexPath.item
                detailVC.book = finalList[item].book
            }
        }
    }
