//
//  File.swift
//  camera
//
//  Created by 中西航平 on 2018/10/13.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit
import SwiftyDropbox
import MBProgressHUD

extension DirectoryViewerController{
    
    func checkSignIN()->Bool{
        guard let client = DropboxClientsManager.authorizedClient else {
            hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
            self.hud.mode = .customView
            self.hud.customView = UIImageView(image: UIImage(named: "failed"))
            self.hud.label.text = "サインインしてください"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
            return false
        }
        return true
    }
    
  
    
    func SignIn(){
        guard let client = DropboxClientsManager.authorizedClient else {
            let application = UIApplication.shared
            DropboxClientsManager.authorizeFromController(application, controller: self, openURL: { url -> Void in
                application.openURL(url)
            })
            return
        }
    }
    func signOut() {
        // サインイン済みの場合
        // 念のためのチェックです。
        if let _ = DropboxClientsManager.authorizedClient {
            // サインアウトする。
            DropboxClientsManager.unlinkClients()
            
            hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
            self.hud.mode = .customView
            self.hud.customView = UIImageView(image: UIImage(named: "checkMark"))
            self.hud.label.text = "ログアウトしました"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
            
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "dropboxLogin")
            // PWEditorでは設定画面のDropboxサインイン/サインアウトボタンの表示ラベルを
            // "未サインイン"に変更する処理を行っています。
        }
    }
}
