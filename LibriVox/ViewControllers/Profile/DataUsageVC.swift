//
//  DataUsageVC.swift
//  LibriVox
//
//  Created by Acesso Gloria MP on 13/07/2023.
//

import UIKit

class DataUsageVC: UIViewController {
    
    @IBOutlet weak var countBooks: UILabel!
    @IBOutlet weak var dataConsumed: UILabel!
    var audiobooks: [(book: AudioBooks_Data, folderSize: Double)] = []
    
    @IBOutlet weak var booksCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let folderSizes = retrieveFolderSizes()
        for folder in folderSizes {
            print("Folder Name: \(folder.folderName), Size: \(folder.folderSize) bytes")
            if let audiobook = getBookByIdCD(id: folder.folderName) {
                audiobooks.append((book: audiobook, folderSize: folder.folderSize))
            }
        }
        /*if !audiobooks.isEmpty{
            countBooks.text = String(audiobooks.count)}*/
        dataConsumed.text = String(format: "%.0f",audiobooks.reduce(0) { $0 + $1.folderSize })
        booksCV.dataSource = self
        booksCV.delegate = self
        booksCV.reloadData()
    }
    
    func retrieveFolderSizes() -> [(folderName: String, folderSize: Double)] {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        var folderSizes: [(folderName: String, folderSize: Double)] = []
        
        do {
            let folderContents = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for folderURL in folderContents where folderURL.hasDirectoryPath {
                let folderName = folderURL.lastPathComponent
                if folderName == "ImgBooks" { continue }
                
                let folderSizeInBytes = self.folderSize(atPath: folderURL.path)
                let folderSizeInMB = Double(folderSizeInBytes) / (1024 * 1024)
                folderSizes.append((folderName: folderName, folderSize: folderSizeInMB))
            }
        } catch {
            print("Error accessing folder contents: \(error)")
        }
        
        return folderSizes
    }


    func folderSize(atPath path: String) -> UInt64 {
        let fileManager = FileManager.default
        var totalSize: UInt64 = 0
        
        guard let fileEnumerator = fileManager.enumerator(atPath: path) else {
            return totalSize
        }
        
        for file in fileEnumerator {
            let filePath = (path as NSString).appendingPathComponent(file as? String ?? "")
            
            do {
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                    totalSize += fileSize
                }
            } catch {
                print("Error retrieving file size: \(error)")
            }
        }
        
        return totalSize
    }
    
    func deleteFolder(withName folderName: String, completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsDirectory.appendingPathComponent(folderName)
        
        do {
            try fileManager.removeItem(at: folderURL)
            completion(true)
        } catch {
            print("Error deleting folder: \(error)")
            completion(false)
        }
    }


}


extension DataUsageVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audiobooks.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = booksCV.dequeueReusableCell(withReuseIdentifier: "DownloadedBooksCell", for: indexPath) as! DownloadedBooksCell
        
        cell.titleBook.text = audiobooks[indexPath.row].book.title
        cell.imageBook.image = nil
        getCoverBook(id:audiobooks[indexPath.row].book._id!){img in
            if let img = img{
                cell.imageBook.loadImage(from: img)
                cell.background.loadImage(from: img)
            }
        }
        cell.bytes.text =  "\(String(format: "%.0f", audiobooks[indexPath.row].folderSize)) MB"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "\(audiobooks[indexPath.row].book.title)", message: "Are you sure you want to delete this book?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.deleteFolder(withName: self.audiobooks[indexPath.row].book._id!) { result in
                if result {
                    self.audiobooks.remove(at: indexPath.row)
                    collectionView.deleteItems(at: [indexPath])
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
           let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
           let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
           return CGSize(width: size, height: size)
       }

}
    

class DownloadedBooksCell: UICollectionViewCell {
    
    @IBOutlet weak var background: BlurredImageView!
    @IBOutlet weak var imageBook: RoundedBookImageView!
    @IBOutlet weak var titleBook: UILabel!
    @IBOutlet weak var bytes: UILabel!
}

