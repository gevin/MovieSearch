//
//  AppDelegate.swift
//  MovieListDemo
//
//  Created by GevinChen on 2019/12/27.
//  Copyright © 2019 GevinChen. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // realm configure
        let schemaVersion: UInt64 = 1
        let realmConfig = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < schemaVersion) {
                
            }
        })
        Realm.Configuration.defaultConfiguration = realmConfig
        let realm = try! Realm(configuration: realmConfig)
        print("realm db:\(realmConfig.fileURL?.absoluteString ?? "")")
        
        // APIClient configure
        let apiClient = APIClient()
                
        
        // clear old data
        try! realm.write {
            realm.deleteAll()
        }
        
        // AppCenter configure
        AppCenter.initial(apiClient: apiClient, realm: realm)
        
        // root UI configure
        let navigationController = UINavigationController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = navigationController
        
        // Coordinator start
        let rootCoordinator = RootCoordinator(navigationController: navigationController, appCenter: AppCenter.shared)
        rootCoordinator.start()
        
        self.window?.makeKeyAndVisible()
        
        return true
    }


}

