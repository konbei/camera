//
//  DirectoryViewerController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/03.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit
import SwiftyDropbox
import MBProgressHUD

//リサイズ方法拡張
extension UIImage {
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,true,0.0/*UIScreen.main.scale*/);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
}


class DirectoryViewerController: UIViewController,UICollectionViewDataSource,
UICollectionViewDelegate {
    
    // 画面を自動で回転させるか
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面の向きを指定
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    
    @IBOutlet weak var cv: UICollectionView!
    var thumbmnailImages:[UIImage] = []
    var file:[(name:String,date:String,modify:Date,image:UIImage?)]!
    var selectRow = 0
    var selectImage:UIImage!
    var selectImagePath:String!
    var selectImageDropboxPath:String?
    let util = Util()
    var selectedDirectoryName = ""
    
    @IBOutlet weak var topBar: UINavigationItem!
    @objc private func editButtonTapped(){
        
        cv.allowsMultipleSelection = true
        
        let doneBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.done, target:self , action: #selector(doneButtonTapped))
        
        self.navigationItem.setRightBarButton(doneBarButtonItem, animated: true)
    }

    

    @objc private func doneButtonTapped(){
        for indexpath in (cv?.indexPathsForSelectedItems)!{
            cv.deselectItem(at: indexpath, animated: false)
        }
        cv.allowsMultipleSelection = false
        let editBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "選択", style: UIBarButtonItem.Style.done, target: self, action: #selector(editButtonTapped))
        
        
        self.navigationItem.setRightBarButton(editBarButtonItem, animated: true)
    }
    
    @IBOutlet weak var underBar: UINavigationBar!
    
    @IBOutlet weak var dropboxItem: UINavigationItem!
    @objc func dropboxTapped(){
        let alert = UIAlertController(title:"Dropboxアクション", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        var title:String = ""
        let client = DropboxClientsManager.authorizedClient
        if  client == nil{
            title = "ログイン"
        }else{
            title = "ログアウト"
        }
        
        let action1 = UIAlertAction(title: title, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            if title == "ログイン"{
                self.SignIn()
            }else{
                self.signOut()
            }
        })
        
        let action2 = UIAlertAction(title: "フォルダ作成", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            self.makeDropboxFolder()
            print("アクション２をタップした時の処理")
        })
        
        var uploadsTitle = ""
        if cv.allowsMultipleSelection{
            uploadsTitle = "アップロード"
        }else{
            uploadsTitle = "バックアップ"
        }
        
        let action3 = UIAlertAction(title: uploadsTitle, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            if uploadsTitle == "アップロード"{
                if self.cv?.indexPathsForSelectedItems?.count == 0{
                    self.hud = MBProgressHUD.showAdded(to: (self.getTopViewController()?.view)!, animated: true)
                    self.hud.mode = .customView
                    self.hud.customView = UIImageView(image: UIImage(named: "failed"))
                    self.hud.label.text = "アップロードする写真がありません"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.hud.animationType = MBProgressHUDAnimation.fade
                        self.hud.hide(animated: true)
                    }
                    return
                }
                var data:[(name:String,date:String,modify:Date,image:UIImage?)] = []
                for i in (self.cv?.indexPathsForSelectedItems)!{
                    data.append(self.file[i.row])
                }
                self.upload(type: "uploads", detta: data)
            }else{
                if self.file.count == 0{
                    self.hud = MBProgressHUD.showAdded(to: (self.getTopViewController()?.view)!, animated: true)
                    self.hud.mode = .customView
                    self.hud.customView = UIImageView(image: UIImage(named: "failed"))
                    self.hud.label.text = "バックアップする写真がありません"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.hud.animationType = MBProgressHUDAnimation.fade
                        self.hud.hide(animated: true)
                    }
                    return
                }
                self.upload(type: "backup", detta: self.file)
            }
            
            print("アクション３をタップした時の処理")
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            print("キャンセルをタップした時の処理")
        })
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func trash(_ sender: Any) {
        var message = ""
        if cv.allowsMultipleSelection{
            if self.cv?.indexPathsForSelectedItems?.count == 0{
                self.hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
                self.hud.mode = .customView
                self.hud.customView = UIImageView(image: UIImage(named: "failed"))
                self.hud.label.text = "削除する写真がありません"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.hud.animationType = MBProgressHUDAnimation.fade
                    self.hud.hide(animated: true)
                }
                return
            }
            message = "選択した写真を削除してもいいですか"
        }else{
            if self.file.count == 0{
                self.hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
                self.hud.mode = .customView
                self.hud.customView = UIImageView(image: UIImage(named: "failed"))
                self.hud.label.text = "削除する写真がありません"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.hud.animationType = MBProgressHUDAnimation.fade
                    self.hud.hide(animated: true)
                }
                return
            }
            message = selectedDirectoryName + "の写真を全て削除してもいいですか？"
        }
        let alert: UIAlertController = UIAlertController(title: "写真削除", message: message, preferredStyle:  UIAlertController.Style.alert)
        
        
        // 削除ボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            // ファイル削除
            (action: UIAlertAction!) -> Void in
            if self.cv.allowsMultipleSelection{
                for i in (self.cv?.indexPathsForSelectedItems)!{
                    do {
                        try self.util.fileManager.removeItem( atPath: self.util.documentPath + "/" + (self.file?[i.row].date)! + "/" + self.file[i.row].name )
                    } catch {
                        //エラー処理
                        print("error")
                    }
                    
                    let client = DropboxClientsManager.authorizedClient
                    client?.files.deleteV2(path: "/" + self.file[i.row].date + "/" + self.file[i.row].name ).response { (result: Files.DeleteResult?, error: CallError<Files.DeleteError>?) in
                        if let error = error {
                            // エラーの場合、処理を終了します。
                            // 必要ならばエラー処理してください。
                            print("dropboxには無いよ〜")
                            return
                        }
                    }
                }
                self.doneButtonTapped()
            }else{
                for i in 0..<self.file.count{
                    do {
                        try self.util.fileManager.removeItem( atPath: self.util.documentPath + "/" + self.file[i].date + "/" + self.file[i].name )
                    } catch {
                        //エラー処理
                        print("error")
                    }
                    
                    let client = DropboxClientsManager.authorizedClient
                    
                    client?.files.deleteV2(path: "/" + self.file[i].date + "/" + self.file[i].name ).response { (result: Files.DeleteResult?, error: CallError<Files.DeleteError>?) in
                        if let error = error {
                            // エラーの場合、処理を終了します。
                            // 必要ならばエラー処理してください。
                            print("dropboxには無いよ〜")
                            return
                        }
                    }
                }
            }
            self.file = self.util.loadImage(selectedDirectoryName: self.selectedDirectoryName)
            self.cv.reloadData()
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            
            (action: UIAlertAction!) -> Void in
            
        })
        
        //  UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func shareAction(_ sender: Any) {
        var image:[UIImage] = []
        if cv.allowsMultipleSelection{
            for i in (cv?.indexPathsForSelectedItems)!{
                image.append(file[i.row].image!)
            }
            
        }else{
            for i in 0..<self.file.count{
                image.append(file[i].image!)
            }
        }
        if image.count == 0{
            self.hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
            self.hud.mode = .customView
            self.hud.customView = UIImageView(image: UIImage(named: "failed"))
            self.hud.label.text = "シェアする写真がありません"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
            return
        }
        let activities = image as [Any]
        let activityViewController = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        // activityViewController.popoverPresentationController?.sourceRect = CGRect(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        self.present(activityViewController,animated: true,completion: nil)
        if cv.allowsMultipleSelection{
            self.doneButtonTapped()
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.underBar.isHidden = false
        cv.delegate = self
        cv.dataSource = self
        
        self.navigationItem.title = self.selectedDirectoryName
        // barのアイテム追加
        let editBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "選択", style: UIBarButtonItem.Style.done, target: self, action: #selector(editButtonTapped))
        self.navigationItem.setRightBarButton(editBarButtonItem, animated: true)
        
        let dropboxImage = UIImage(named: "Dropbox")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        let dropboxButton = UIBarButtonItem(image: dropboxImage, landscapeImagePhone: dropboxImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.dropboxTapped))
        dropboxItem.setLeftBarButton(dropboxButton, animated: false)
        
        
        
        let syncImage = UIImage(named: "sync")?.withRenderingMode(UIImage.RenderingMode.automatic)
        let syncButton = UIBarButtonItem(image: syncImage, landscapeImagePhone: syncImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.syncDropbox))
        
        let barButtonItems = [dropboxButton,syncButton]
        editBarButtonItem.tintColor = UIColor.white
        dropboxItem.setLeftBarButtonItems(barButtonItems, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      //   self.navigationController?.isNavigationBarHidden = true
        //選択解除
        for indexpath in (cv?.indexPathsForSelectedItems)!{
            cv.deselectItem(at: indexpath, animated: false)
        }
        
        
        file = util.loadImage(selectedDirectoryName: self.selectedDirectoryName)
        thumbmnailImages = []
        cv.reloadData()
    }

   
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        //セルのクラス作ってそこでスクロールした時の初期化実装してます
        let cell:DirectoryViewrCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath) as! DirectoryViewrCell
        
        var cellImage:UIImage?
        if let image = self.file[indexPath.row].image{
            cellImage = image
        }else{
            return cell
        }
        
        let selectView = CheckBoxView(frame: CGRect(x:0,y:0,width:23,height:23), selected: true)
        cell.selectedBackgroundView = selectView
        
        
        var thumbnail:UIImage? = nil
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "imageSetting",attributes: .concurrent)
        group.enter()
        queue.async(group: group) {
            //サムネイル作成方法変更
            thumbnail = cellImage?.reSizeImage(reSize:CGSize(width: 81, height: 81))
            group.leave()
        }
        group.notify(queue: .main){
            cell.img.image = thumbnail
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //よくよく考えたら1セクションあたりのあセル表示数を固定する必要ないと思ったので変更
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return file.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cv.allowsMultipleSelection{
            let cell:DirectoryViewrCell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath) as! DirectoryViewrCell
            print(cv.indexPathsForSelectedItems)
        }else{
            if selectedDirectoryName == "All"{
                selectImagePath = self.util.documentPath + "/" + file[indexPath.row].date + "/" + file[indexPath.row].name
                selectImageDropboxPath = "/" + file[indexPath.row].date + "/" + file[indexPath.row].name
                
            }else{
                //選択した写真のパス
                selectImagePath = self.util.documentPath + "/" + selectedDirectoryName + "/" + file[indexPath.row].name
                selectImageDropboxPath = "/" + selectedDirectoryName + "/" + file[indexPath.row].name
            }
            self.selectRow = indexPath.row
            // [indexPath.row] から画像名を探し、UImage を設定
            selectImage = file[indexPath.row].image
            if selectImage != nil {
                // SubViewController へ遷移するために Segue を呼び出す
                performSegue(withIdentifier: "selectedImage",sender: nil)
            }
        }
        
    }
    
    //選択した写真と写真のパス送る
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectedImage"){
            (segue.destination as! SelectedImageViewController).selectedDirectory = self.selectedDirectoryName
            (segue.destination as! SelectedImageViewController).movedPreview = false
            
            (segue.destination as! SelectedImageViewController).selectRow = self.selectRow
        }
    }
    
    
    //use DropBox
    
    let client = DropboxClientsManager.authorizedClient
    
    var holderName:[String] = []
    var exsistFolderName:[String] = []
    //var exsistDataName:[String] = []
    
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
    
    
    var failed:Bool = false
    var finishCount = 0
    
    func makeFolder(path:String,count:Int){
        
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
        if !checkSignIN(){
            return
        }
        var dattaName:[String] = []
        let client = DropboxClientsManager.authorizedClient
        hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
        self.hud.label.text = "フォルダ作成中"

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
            self.failed = false
            self.finishCount = 0
            if holderName.count != 0{
                for i in 0..<holderName.count{
                    self.makeFolder(path: "/" + holderName[i],count:holderName.count)
                }
            }else{
                self.makeFolderResultHUD(bool: true)
            }
        }
        
    }
    
    
    func makeUploadsResultHUD(bool:Bool){
        self.hud.hide(animated: false)
        hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
        self.hud.mode = .customView
        if bool{
            self.hud.customView = UIImageView(image: UIImage(named: "checkMark"))
            self.hud.label.text = "アップロード成功"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
        }else{
            self.hud.customView = UIImageView(image: UIImage(named: "failed"))
            self.hud.label.text = "アップロード失敗"
            self.hud.detailsLabel.text = "アップロードし直してください"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
        }
        
    }
    
    func upload(type:String,detta:[(name:String,date:String,modify:Date,image:UIImage?)]) {
        if !checkSignIN(){
            return
        }
        if detta.count == 0{
            hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
            self.hud.mode = .customView
            self.hud.customView = UIImageView(image: UIImage(named: "failed"))
            self.hud.label.text = "アップロードする写真がありません"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
            return
        }
        
        self.hud = MBProgressHUD.showAdded(to: (getTopViewController()?.view)!, animated: true)
        self.hud.label.text = "アップロード中"
        hud.detailsLabel.text = "戻るとバックグラウンドで実行されます"
        hud.button.addTarget(self, action: #selector(syncBackGround), for: .touchUpInside)
        hud.button.setTitle("バックグラウンド", for: UIControl.State.normal)
        
        let client = DropboxClientsManager.authorizedClient
        let f = DateFormatter()
        f.dateFormat = "yyyy_MM_dd_HH:mm"
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        let path = "/" + type + "/" + self.selectedDirectoryName + "-" + f.string(from: now)
        failed = false
        client?.files.createFolderV2(path: path).response { response, error in
            if let error = error {
                self.makeUploadsResultHUD(bool: false)
                return
            }
            
            guard let respone = response else{
                self.makeUploadsResultHUD(bool: false)
                return
            }
            var count = 0
            for i in 0..<detta.count{
                let data:Data = detta[i].image!.pngData()!
                
                self.client?.files.upload(path: path + "/" + detta[i].name, input: data).response { response, error in
                    if let error = error {
                        self.failed = true
                        count = count + 1
                        if count == detta.count{
                             self.makeUploadsResultHUD(bool: false)
                        }
                        // エラーの場合、処理を終了します。
                        // 必要ならばエラー処理してください。
                        return
                    }
                    
                    guard let response = response else {
                        self.failed = true
                        count = count + 1
                        if count == detta.count{
                            self.makeUploadsResultHUD(bool: false)
                        }
                        return
                    }
                    

                    
                    count = count + 1
                    if count == detta.count && self.failed{
                        self.makeUploadsResultHUD(bool: false)
                    }else if count == detta.count{
                        self.makeUploadsResultHUD(bool: true)
                    }
                }
            }
        }
    }
           

    
   
    
    //Setting Dropbox
    var hud = MBProgressHUD()

    
    @objc func syncDropbox(){
        if !checkSignIN(){
            return
        }
        
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        hud.label.text = "同期中"
        hud.detailsLabel.text = "戻るとバックグラウンドで実行されます"
        hud.button.addTarget(self, action: #selector(syncBackGround), for: .touchUpInside)
        hud.button.setTitle("バックグラウンド", for: UIControl.State.normal)
        
        let defaults = UserDefaults.standard
        
        var dropboxFileName:[String] = []
        var errorFolder:[String] = []

        
        var boolArry = [Bool](repeating: false,count: 37)
        
        var directoryIsSync:[Bool] = defaults.array(forKey: "selectedDirectorySync") as? [Bool] ?? boolArry
        
        let syncing = directoryIsSync.filter({$0 == true})
        if syncing.count != 0 {
            hud.hide(animated: false)
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .customView
            hud.label.text = "前回の同期が終わるまでお待ち下さい"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
            
            return
        }
        
       
        if selectedDirectoryName == "All"{
            self.holderName = ["Mon1","Mon2","Mon3","Mon4","Mon5","Mon6","Mon0","Tues1","Tues2","Tues3","Tues4","Tues5","Tues6","Tues0","Wednes1","Wednes2","Wednes3","Wednes4","Wednes5","Wednes6","Wednes0","Thurs1","Thurs2","Thurs3","Thurs4","Thurs5","Thurs6","Thurs0","Fri1","Fri2","Fri3","Fri4","Fri5","Fri6","Fri0","Satur","Sun"]
        }else{
            self.holderName = [selectedDirectoryName]
        }
        
        
        
        
        var directoryCount = 0
        
        for j in 0..<holderName.count{
            
            directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as? [Bool] ?? boolArry
             if directoryIsSync[j]{
                break
            }
            directoryIsSync[j] = true
            //save
            defaults.set(directoryIsSync as [Any?], forKey: "selectedDirectorySync")
            defaults.synchronize()
            
            var directoryLocalData:[String] = defaults.stringArray(forKey: self.holderName[j]) ?? []

            
            //dropboxのファイル一覧取得
            let _ = client?.files.listFolder(path: "/" + self.holderName[j]).response { response, error in
                if let error = error {
                    //ファイル更新がない場合
                    errorFolder.append(self.holderName[j])
                    
                    directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                    directoryIsSync[j] = false
                    //save
                    defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                    defaults.synchronize()
                    
                    
                    let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                    
                    if filterDirectoryIsSync.count == directoryIsSync.count{
                        self.hud.hide(animated: false)
                        self.finishedSyncHUD(errorFolder: errorFolder)
                    }
                    // エラーの場合、処理を終了します。
                    // 必要ならばエラー処理してください。
                    print("error")
                    return
                }
                
                guard let respone = response else{
                    errorFolder.append(self.holderName[j])
                    directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                    directoryIsSync[j] = false
                    //save
                    defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                    defaults.synchronize()
                    
                    
                    let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                    
                    if filterDirectoryIsSync.count == directoryIsSync.count{
                        self.hud.hide(animated: false)
                        self.finishedSyncHUD(errorFolder: errorFolder)
                    }
                    print("response")
                    return
                }
                
                let localFolderDirectory = self.util.documentPath + "/" + self.holderName[j]
                
                // エントリー数分繰り返します。
                // entryオブジェクトからディレクトリ、ファイル情報が取得できます。
                
                dropboxFileName = []
                
                for entry in (response?.entries)!{
                    // 名前
                    let name = entry.name
                    dropboxFileName.append(name)

                }
                
                
                
                //ドロップボックスから削除されたデータをローカルデータも削除
                if !directoryLocalData.isEmpty  {
                    for i in 0..<directoryLocalData.count{
                        if !dropboxFileName.contains(directoryLocalData[i]){
                            do {
                                try self.util.fileManager.removeItem( atPath: localFolderDirectory + "/" + directoryLocalData[i])
                                
                                self.file = self.util.loadImage(selectedDirectoryName: self.selectedDirectoryName)
                                self.cv.reloadData()
                                
                            } catch {
                                //エラー処理
                                print("error")
                            }
                        }
                    }
                }
                
                directoryLocalData = []
                
                //アップロードされていないデータ一覧取得&&現在ファイルの名前入れる
                var uploadData:[(name:String,date:String,modify:Date,image:UIImage?)]? = []
                
                //ローカルディレクトリのデータ抽出
                let directoryFile = self.file.filter {$0.date == self.holderName[j]}
                
                for i in 0..<directoryFile.count{
                    if !dropboxFileName.contains(directoryFile[i].name) {
                        uploadData?.append(directoryFile[i])
                        
                    }else{
                        // アップロード済みのものを追加
                         directoryLocalData.append(directoryFile[i].name)
                    }
                   
                }
                
                //ローカルファイル名保存
                self.userDefaultSave(data: directoryLocalData, path: self.holderName[j])
                defaults.synchronize()
                
                //ローカルファイルになく、ドロップボックスにあるファイル一覧をの名前を取得
                
                var downloadFileName:[String]? = []
                
                for i in 0..<dropboxFileName.count{
                    if self.util.fileManager.fileExists(atPath: localFolderDirectory + "/" + dropboxFileName[i]) != true{
                        downloadFileName?.append(dropboxFileName[i])
                    }
                }

                
                
                var downloadcount = 0
                var uploadcount = 0
                
                
            
                
                if downloadFileName?.count == 0 && uploadData?.count == 0{
                    //ディレクトリ同期完了
                    directoryCount = directoryCount + 1
                    

                    directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                        directoryIsSync[j] = false
                        //save
                        defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                        defaults.synchronize()
             
                    
                    let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                    
                    if filterDirectoryIsSync.count == directoryIsSync.count{
                        self.hud.hide(animated: false)
                        self.finishedSyncHUD(errorFolder: errorFolder)
                    }
                }
                
                print("\(directoryCount)/\(self.holderName.count)")
                print(self.holderName[j])
                print(uploadData?.count)
                
                //アップロード
                if uploadData != nil{
                    //upload
                    for i in 0..<uploadData!.count{
                        let data:Data = (uploadData?[i].image!.pngData()!)!
                        
                        self.client?.files.upload(path: "/" + (uploadData?[i].date)! + "/" + (uploadData?[i].name)!, input: data).response { response, error in
                            if let error = error {
                                errorFolder.append(self.holderName[j])
                                directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                                directoryIsSync[j] = false
                                //save
                                defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                                defaults.synchronize()
                                
                                
                                let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                                
                                if filterDirectoryIsSync.count == directoryIsSync.count{
                                    self.hud.hide(animated: false)
                                    self.finishedSyncHUD(errorFolder: errorFolder)
                                }
                                // エラーの場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            
                            guard let response = response else {
                                errorFolder.append(self.holderName[j])
                                directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                                directoryIsSync[j] = false
                                //save
                                defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                                defaults.synchronize()
                                
                                
                                let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                                
                                if filterDirectoryIsSync.count == directoryIsSync.count{
                                    self.hud.hide(animated: false)
                                    self.finishedSyncHUD(errorFolder: errorFolder)
                                }
                                return
                            }
                            
                            uploadcount = uploadcount + 1
                            
                            //アップロード情報セーブ
                            directoryLocalData = defaults.stringArray(forKey: self.holderName[j]) ?? []
                            directoryLocalData.append((uploadData![i].name))
                            self.userDefaultSave(data: directoryLocalData, path: self.holderName[j])
                            defaults.synchronize()
                            
                            
                            if downloadcount == downloadFileName?.count && uploadcount == uploadData?.count{
                                
                                directoryCount = directoryCount + 1
                                
                                print("\(directoryCount)/\(self.holderName.count)")

                                
                                //ディレクトリ同期完了
                                directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                                directoryIsSync[j] = false
                                //save
                                defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                                defaults.synchronize()
 
                                let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                                //全体同期完了
                                if filterDirectoryIsSync.count == directoryIsSync.count{
                                    self.hud.hide(animated: false)
                                    self.hud = MBProgressHUD.showAdded(to:(self.getTopViewController()?.view)!,animated: true)
                                    self.hud.mode = .customView
                                    self.hud.customView = UIImageView(image: UIImage(named: "checkMark"))
                                    self.hud.label.text = "\(self.selectedDirectoryName)の同期完了"
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                         self.hud.animationType = MBProgressHUDAnimation.fade
                                         self.hud.hide(animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                //ダウンロード
                if downloadFileName != []{
                    for i in 0..<downloadFileName!.count{
                        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                            let path = "file://" + localFolderDirectory + "/" + (downloadFileName?[i])!
                            let directoryURL = NSURL(string: path)! as URL
                            
                            return directoryURL
                        }
                        
                        self.client?.files.download(path: "/" + self.holderName[j] + "/" + (downloadFileName?[i])!, destination: destination).response { response, error in
                            if let error = error {
                                errorFolder.append(self.holderName[j])
                                directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                                directoryIsSync[j] = false
                                //save
                                defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                                defaults.synchronize()
                                
                                
                                let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                                
                                if filterDirectoryIsSync.count == directoryIsSync.count{
                                    self.hud.hide(animated: false)
                                    self.finishedSyncHUD(errorFolder: errorFolder)
                                }
                                // エラーの場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            
                            
                            
                            guard let response = response else {
                                errorFolder.append(self.holderName[j])
                                directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                                directoryIsSync[j] = false
                                //save
                                defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                                defaults.synchronize()
                                
                                
                                let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                                
                                if filterDirectoryIsSync.count == directoryIsSync.count{
                                    self.hud.hide(animated: false)
                                    self.finishedSyncHUD(errorFolder: errorFolder)
                                }
                                // レスポンスがない場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            
                            downloadcount = downloadcount + 1
                            
                            
                            
                            
                            if downloadcount == downloadFileName?.count && uploadcount == uploadData?.count{
                                //ディレクトリ同期完了
                                directoryIsSync = defaults.array(forKey: "selectedDirectorySync") as! [Bool]
                                directoryIsSync[j] = false
                                    //save
                                    defaults.set(directoryIsSync, forKey: "selectedDirectorySync")
                                    defaults.synchronize()
                                
                                
                                let filterDirectoryIsSync = directoryIsSync.filter {$0 == false }
                                //全体同期完了
                                if filterDirectoryIsSync.count == directoryIsSync.count{
                                    self.hud.hide(animated: false)
                                    self.finishedSyncHUD(errorFolder: errorFolder)
                                }
                            }
                            
                            //ダウンロード情報セーブ
                            directoryLocalData = defaults.stringArray(forKey: self.holderName[j]) ?? []
                            directoryLocalData.append((downloadFileName?[i])!)
                            self.userDefaultSave(data: directoryLocalData, path: self.holderName[j])
                            defaults.synchronize()
                            
                            self.file = self.util.loadImage(selectedDirectoryName: self.selectedDirectoryName)
                            self.thumbmnailImages = []
                            self.cv.reloadData()
                        }
                    }
                }
            }
        }
        
        
    }
    
    func userDefaultSave(data:[String],path:String){
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: path)
        defaults.synchronize()
    }
    
    @objc func syncBackGround(){
        self.hud.hide(animated: false)
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .customView
        //self.hud.customView = UIImageView(image: UIImage(named: "checkMark"))
        self.hud.label.numberOfLines = 2
        self.hud.detailsLabel.adjustsFontSizeToFitWidth = true
        self.hud.label.text = "処理はアプリを開いている間\nバックグラウンドで行われます"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.hud.animationType = MBProgressHUDAnimation.fade
            self.hud.hide(animated: true)
        }
    }
    
    
    //現在いるビューコントローラーを取ってくる
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

    func finishedSyncHUD(errorFolder:[String]){
        if errorFolder.count != 0{
            self.hud = MBProgressHUD.showAdded(to:(self.getTopViewController()?.view)!,animated: true)
            self.hud.mode = .customView
            self.hud.customView = UIImageView(image: UIImage(named: "failed"))
            self.hud.label.text = "一部同期失敗"
            let string = errorFolder.joined(separator: ",")
            self.hud.detailsLabel.numberOfLines = 2
            self.hud.detailsLabel.adjustsFontSizeToFitWidth = true
            self.hud.detailsLabel.text = "\(string)の同期に失敗しました\n同期し直してください"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
        }else{
            self.hud = MBProgressHUD.showAdded(to:(self.getTopViewController()?.view)!,animated: true)
            self.hud.mode = .customView
            self.hud.customView = UIImageView(image: UIImage(named: "checkMark"))
            self.hud.label.text = "\(self.selectedDirectoryName)の同期完了"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                self.hud.animationType = MBProgressHUDAnimation.fade
                self.hud.hide(animated: true)
            }
        }
    }
}

