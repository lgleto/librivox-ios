//
//  AppDelegate.swift
//  LibriVox
//
//  Created by Leandro Silva on 16/03/2023.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import SwaggerClient
import Alamofire
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestore
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    class AppRequestBuilderFactory: RequestBuilderFactory {
        func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
            return AppRequestBuilder<T>.self
        }
        
        func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
            return AppDecodableRequestBuilder<T>.self
        }
    }
    
    class AppDecodableRequestBuilder<T: Decodable>: AlamofireDecodableRequestBuilder<T> {
        override public func createSessionManager() -> Alamofire.SessionManager {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = buildHeaders()
            configuration.timeoutIntervalForRequest = TimeInterval(90)
            configuration.timeoutIntervalForResource = TimeInterval(120)
            configuration.requestCachePolicy = .useProtocolCachePolicy
            return Alamofire.SessionManager(configuration: configuration)
        }
    }
    
    class AppRequestBuilder<T>: AlamofireRequestBuilder<T> {
        override public func createSessionManager() -> Alamofire.SessionManager {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = buildHeaders()
            configuration.timeoutIntervalForRequest = TimeInterval(90)
            configuration.timeoutIntervalForResource = TimeInterval(120)
            configuration.requestCachePolicy = .useProtocolCachePolicy
            return Alamofire.SessionManager(configuration: configuration)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        print("Database path", URL.documentsDirectory)
        let db = Firestore.firestore()
        db.settings = settings
        
        SwaggerClientAPI.requestBuilderFactory = AppRequestBuilderFactory()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func resetCoreDataSchema() {
        if let persistentStore = persistentContainer.persistentStoreCoordinator.persistentStores.last {
            let storeURL = persistentContainer.persistentStoreCoordinator.url(for: persistentStore)
            
            do {
                try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            } catch {
                print("failed to destroy persistent store:", error.localizedDescription)
            }
            
            do {
                try persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                print("failed to re-add persistent store:", error.localizedDescription)
            }
        }
        
    }}

