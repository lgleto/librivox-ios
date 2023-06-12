//
//  SectionsTVC.swift
//  LibriVox
//
//  Created by Leandro Silva on 19/05/2023.
//

import UIKit
import SwaggerClient

class SectionsTVC: UITableViewController {
    
    enum Content {
    case empty
    case error(title: String)
    case info(title: String)
  }
    
    static func showSections(parentVC: UIViewController,
                             title: String,
                             book: Audiobook,
                             onCallback: ((Bool, Audiobook, Int) -> Void)?)
    {
        SectionsTVC.showSections(parentVC: parentVC, content: .error(title: title), book: book, onCallback: onCallback)
    }
    
    static func showSections(parentVC: UIViewController,
                             content: Content,
                             book: Audiobook,
                             onCallback: ((Bool,Audiobook, Int) -> Void)?)
    {
        let storyBoard = UIStoryboard(name: "HomePage", bundle: nil)
        let vc: SectionsTVC = storyBoard.instantiateViewController(withIdentifier: "SectionsTVC") as! SectionsTVC
        vc.book = book
        vc.callback = { yes, book, selectedSections in
            if let callback = onCallback {
                callback(yes, book, selectedSections)
            }
        }
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        
        parentVC.present(vc, animated: true, completion: nil)
    }
    
    
    
    
    @IBOutlet var SectionsTV: UITableView!
    var book : Audiobook?
    weak var delegado: DataDelegate?
    var callback: ((Bool , Audiobook, Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SectionsTV.dataSource = self
        SectionsTV.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SectionsTV.dequeueReusableCell(withIdentifier: "SectionsCell", for: indexPath) as! SectionsCell
        let section = book?.sections?[indexPath.row]
        
        let seconds = Int(section?.playtime ?? "Not found") ?? 0
        
        cell.titleSection.text = section?.title
        cell.durationSection.text! = "Duration: \(secondsToMinutes(seconds: seconds))min "
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            if let c = self.callback {
                c(true, self.book!, (indexPath.row + 1))
            }        //performSegue(withIdentifier: "SectionsToPlayer", sender: indexPath.row + 1)
        }
        
        /*
         override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
         
         // Configure the cell...
         
         return cell
         }
         */
        
        /*
         // Override to support conditional editing of the table view.
         override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
         }
         */
        
        /*
         // Override to support editing the table view.
         override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
         // Delete the row from the data source
         tableView.deleteRows(at: [indexPath], with: .fade)
         } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
         }
         */
        
        /*
         // Override to support rearranging the table view.
         override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
         
         }
         */
        
        /*
         // Override to support conditional rearranging of the table view.
         override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
         return true
         }
         */
        
        
    }
}
