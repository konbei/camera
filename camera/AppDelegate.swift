//
//  AppDelegate.swift
//  camera
//
//  Created by 中西航平 on 2018/09/23.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit
import CoreData
import SwiftyDropbox
import MBProgressHUD


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "dropboxLogin")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.LoginResultHUD(bool: true)
                    self.makeDropboxFolder()
                }
                print("Success! User is logged into Dropbox.")
            case .cancel:
                LoginResultHUD(bool: false)
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                LoginResultHUD(bool: false)
                print("Error: \(description)")
            }
        }
        return true
    }

    var hud = MBProgressHUD()
    let client = DropboxClientsManager.authorizedClient
    var storyboard:UIStoryboard =  UIStoryboard(name: "Main",bundle:nil)
    
    func LoginResultHUD(bool:Bool){
        self.hud = MBProgressHUD.showAdded(to: (self.getTopViewController()?.view)!, animated: true)
        if bool{
            self.hud.label.text = "ログイン成功"
            self.hud.detailsLabel.numberOfLines = 2
            self.hud.detailsLabel.text = "引き続きフォルダを設定しています\nお待ち下さい"
            
        }else{
             self.hud.mode = .customView
            self.hud.customView = UIImageView(image: UIImage(named: "failed"))
            self.hud.label.text = "ログイン失敗"
            self.hud.detailsLabel.text = "ログインし直してください"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
        }
    }
    
    func makeFolderResultHUD(bool:Bool){
        self.hud.hide(animated: false)

       
        hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
        self.hud.mode = .customView
        if bool{
            self.hud.customView = UIImageView(image: UIImage(named: "checkMark"))
            self.hud.label.text = "フォルダ作成成功"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
        }else{
            self.hud.customView = UIImageView(image: UIImage(named: "failed"))
            self.hud.label.text = "フォルダ作成失敗"
            self.hud.detailsLabel.text = "フォルダ作成し直してください"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
        }
        
    }
    
    var finishCount = 0
    var failed:Bool = false
    func makeFolder(path:String,i:Int,count:Int){
        let client = DropboxClientsManager.authorizedClient
        client?.files.createFolderV2(path: path).response { response, error in
            if let error = error {
                self.failed = true
                self.finishCount = self.finishCount + 1
                if self.finishCount == count{
                    self.makeFolderResultHUD(bool: false)
                }
                return
            }
            
            guard let respone = response else{
                self.failed = true
                self.finishCount = self.finishCount + 1
                if self.finishCount == count{
                    self.makeFolderResultHUD(bool: false)
                }
                return
            }
            
            self.finishCount = self.finishCount + 1
            
            if self.finishCount == count && !self.failed{
                self.makeFolderResultHUD(bool: true)
            }else if self.finishCount == count{
                self.makeFolderResultHUD(bool: false)
            }
            
            
        }
    }
    
    func detectNewFolder(exsistFolder:[String])->[String]{
       var holderName = ["Mon1","Mon2","Mon3","Mon4","Mon5","Mon6","Mon0","Tues1","Tues2","Tues3","Tues4","Tues5","Tues6","Tues0","Wednes1","Wednes2","Wednes3","Wednes4","Wednes5","Wednes6","Wednes0","Thurs1","Thurs2","Thurs3","Thurs4","Thurs5","Thurs6","Thurs0","Fri1","Fri2","Fri3","Fri4","Fri5","Fri6","Fri0","Satur","Sun","uploads","backup"]
        for i in 0..<exsistFolder.count{
            holderName.remove(at: holderName.index(of: exsistFolder[i])!)
        }
        return holderName
    }
    
    func makeDropboxFolder(){
        var dattaName:[String] = []
        let client = DropboxClientsManager.authorizedClient
        
        let _ = client?.files.listFolder(path: "").response { response, error in
            if let error = error {
                self.makeFolderResultHUD(bool: false)
                // エラーの場合、処理を終了します。
                // 必要ならばエラー処理してください。
                return
            }
            
            
            guard let respone = response else{
                self.makeFolderResultHUD(bool: false)
                return
            }
            
            // エントリー数分繰り返します。
            // entryオブジェクトからディレクトリ、ファイル情報が取得できます。
            for entry in (response?.entries)!{
                // 名前
                let name = entry.name
                dattaName.append(name)
                //print(entry.name)
            }
            let holderName = self.detectNewFolder(exsistFolder: dattaName)
           self.finishCount = 0
            self.failed = false
            if holderName.count != 0{
                for i in 0..<holderName.count{
                    self.makeFolder(path: "/" + holderName[i],i:i,count:holderName.count)
                    
                }
            }else{
                self.makeFolderResultHUD(bool: true)
            }
            
        }
        
    }
    
    
    func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewControlelr: UIViewController = rootViewController
            
            while let presentedViewController = topViewControlelr.presentedViewController {
                topViewControlelr = presentedViewController
            }
            
            return topViewControlelr
        } else {
            return nil
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // アプリキーを登録します。
        // アプリキーは事前準備で入手してください。
        DropboxClientsManager.setupWithAppKey("o95fn67p67nb8xr")
        let defaults = UserDefaults.standard
        let boolArry = [Bool](repeating: false,count: 37)
        
        
        defaults.set(boolArry, forKey: "selectedDirectorySync")
        defaults.synchronize()
    
            // Override point for customization after application launch.
            return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//saveContext()
       
    }

   
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SettingsData2")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    }
    
    


