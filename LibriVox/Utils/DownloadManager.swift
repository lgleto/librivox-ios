//
//  DownloadManager.swift
//  DirectView
//
//  Created by Lourenço Gomes on 04/01/2022.
//  Copyright © 2022 Lourenço Gomes. All rights reserved.
//

import Foundation


class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {

    static var shared = DownloadManager()
    
    /*
    typealias ProgressHandler = (Float, String?) -> ()
    typealias DownloadCompletedHandler = (URL) -> ()

    var onProgress : ProgressHandler? {
        didSet {
            if onProgress != nil {
                let _ = activate()
            }
        }
    }

    var onDowloadCompleted : DownloadCompletedHandler? {
        didSet {
            if onDowloadCompleted != nil {
                let _ = activate()
            }
        }
    }*/
    
    override private init() {
        super.init()
    }

    
    func activate() -> URLSession {
       let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
       //if UserDefaults.API_TOKEN.count > 0 {
       //    config.httpAdditionalHeaders = ["Authorization": "OAuth \(UserDefaults.standard.API_TOKEN)"  ]
       //}
       // Warning: If an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one with the old delegate object attached!
       return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
   }

    private func calculateProgress(downloadTask: URLSessionDownloadTask, progress: Float,  completionHandler : @escaping (Float, Int64, Int64) -> ()) {
        DispatchQueue.main.async() { () -> Void in
            completionHandler(progress, downloadTask.countOfBytesReceived, downloadTask.countOfBytesExpectedToReceive)
        }
    }

    var update = 29

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            if let onProgress = onProgress {
                var progress : Float = 0.0
                if downloadTask.countOfBytesExpectedToReceive > 0 {
                    progress = Float(downloadTask.countOfBytesReceived) / Float(downloadTask.countOfBytesExpectedToReceive)
                }
                
                
                if update > 30 || progress >= 1.0{
                    DispatchQueue.main.async() { () -> Void in
                        self.calculateProgress(downloadTask: downloadTask, progress: progress, completionHandler: onProgress)
                    }
                    update = 0
                }
                update += 1
            }
            
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            print("Progress \(downloadTask) \(progress)")
        }
    }
    

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
        
        if let url = destinationURL {
            do {
                print("Download finished: \(url)")
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("erro a remover no url")
                }
                do {
                    try FileManager.default.copyItem(at: location, to: url)
                } catch {
                    print("erro a copiar item")
                }
                do {
                    try FileManager.default.removeItem(at: location)
                } catch {
                    print("erro a apagar na localização primaria")
                }
                
                
                
                
                
                if let originalUrl: URL = downloadTask.originalRequest?.url {
                    if let onCompletion = onCompletion {
                        DispatchQueue.main.async() { () -> Void in
                            self.downloadComplete(localURL: url, downloadURL: originalUrl, completionHandler: onCompletion)
                        }
                    }
                }
            }
        }
    }
    
    func cancelDownload() {
            task?.cancel()
            OperationQueue().cancelAllOperations()
    }
    
    private var destinationURL : URL?
    private var onProgress : ((Float, Int64, Int64)->())?
    private var onCompletion : ((Error?, URL, URL)->())?
    private var task : URLSessionDownloadTask?
    
    
    func addDownload(url: URL ,
                     destinationURL: URL,
                     onProgress: @escaping (Float, Int64, Int64)->(),
                     onCompletion: @escaping (Error?, URL, URL)->()){
        task = activate().downloadTask(with: url)
        self.destinationURL = destinationURL
        task!.resume()
        self.onProgress = onProgress
        self.onCompletion = onCompletion
        
    }
    
    
    private func downloadComplete(localURL: URL, downloadURL: URL, completionHandler : @escaping (Error?,URL, URL) -> ()) {
        DispatchQueue.main.async() { () -> Void in
            completionHandler(nil, downloadURL, localURL)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(error )")
    }
    
}

