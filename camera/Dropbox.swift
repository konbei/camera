//
//  File.swift
//  camera
//
//  Created by 中西航平 on 2018/10/13.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit
import SwiftyDropbox
extension DirectoryViewerController{
    
    func makeFolder(path:String){
        self.client?.files.createFolderV2(path: path).response { response, error in
            if let error = error {
                // エラーの場合、処理を終了します。
                // 必要ならばエラー処理してください。
                return
            }
            
            guard let respone = response else{
                return
            }
        }
    }
    
    func detectNewFolder(exsistFolder:[String]){
        holderName = ["Mon1","Mon2","Mon3","Mon4","Mon5","Mon6","Mon0","Tues1","Tues2","Tues3","Tues4","Tues5","Tues6","Tues0","Wednes1","Wednes2","Wednes3","Wednes4","Wednes5","Wednes6","Wednes0","Thurs1","Thurs2","Thurs3","Thurs4","Thurs5","Thurs6","Thurs0","Fri1","Fri2","Fri3","Fri4","Fri5","Fri6","Fri0","Satur","Sun"]
        for i in 0..<exsistFolder.count{
            holderName.remove(at: holderName.index(of: exsistFolder[i])!)
        }
    }
    
    func checkSignIn(){
        guard let client = DropboxClientsManager.authorizedClient else {
            let application = UIApplication.shared
            DropboxClientsManager.authorizeFromController(application, controller: self, openURL: { url -> Void in
                application.openURL(url)
            })
            return
        }
    }
    
}
