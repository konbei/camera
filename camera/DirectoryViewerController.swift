//
//  DirectoryViewerController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/03.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit
import SwiftyDropbox

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
UICollectionViewDelegate,UICollectionViewDataSourcePrefetching {
    
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
    
    var thumbmnailImages:[UIImage] = []
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    
        
    }
    
    
    @IBOutlet weak var cv: UICollectionView!
    
    var file:[(name:String,date:String,modify:Date,image:UIImage?)]!
    
     //タップされた授業の曜日と時間を取ってくる
    var selectedDirectoryName = ""
    private var fileNames:[String] = []
    private var fileImages:[UIImage] = []
    private let DocumentPath = NSHomeDirectory() + "/Documents"
    let fileManager = FileManager.default
    
    private var daycounts = 7
    private var classcounts = 6
    func numberday(num:Int) ->String{
        switch num{
        case 0:
            return "Mon"
        case 1:
            return "Tues"
        case 2:
            return "Wednes"
        case 3:
            return "Thurs"
        case 4:
            return "Fri"
        case 5:
            return "Satur"
        case 6:
            return "Sun"
        default:
            return ""
        }
        
    }
    
    func stringInt(int:String)->Int{
        let splitNumbers = (int.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
        let number = splitNumbers.joined()
        return Int(number)!
    }
    
    //タップされた授業の写真を取ってくる
    func loadImage(){
        let holderDirectory = DocumentPath + "/" + selectedDirectoryName
        fileNames = []
        fileImages = []
        file = []
   
        //ディレクトリからファイルの名前を取ってくる
        if selectedDirectoryName == "All"{
            for day in 0..<daycounts{
                let directoryPath = DocumentPath + "/" + numberday(num: day)
                do{
                    try fileNames = FileManager.default.contentsOfDirectory(atPath: directoryPath)
                    if fileNames.count != 0{
                        for i in 0..<fileNames.count{
                            var item:NSDictionary?
                            do{
                                item = try fileManager.attributesOfItem(atPath: directoryPath + "/" + fileNames[i]) as NSDictionary?
                            }catch{
                            }
                            file.append((name: fileNames[i], date: numberday(num:day), modify: (item?.fileCreationDate())!, image: nil))
                        }
                    }
                }catch{
                }
                for classes in 0...classcounts{
                    let directoryPath = DocumentPath + "/" + numberday(num: day) + "\(classes)"
                    do{
                        try fileNames = FileManager.default.contentsOfDirectory(atPath: directoryPath)
                        if fileNames.count != 0{
                            for i in 0..<fileNames.count{
                                var item:NSDictionary?
                                do{
                                    item = try fileManager.attributesOfItem(atPath: directoryPath + "/" + fileNames[i]) as NSDictionary?
                                }catch{
                                }
                                
                                file.append((name: fileNames[i], date: numberday(num:day) + "\(classes)", modify: (item?.fileCreationDate())!, image: nil))
                            }
                        }
                    }catch{
                    }
                }
            }
        }else{
            do{
                try fileNames = FileManager.default.contentsOfDirectory(atPath: holderDirectory)
                for i in 0..<fileNames.count{
                    var item:NSDictionary?
                    do{
                        item = try fileManager.attributesOfItem(atPath: holderDirectory + "/" + fileNames[i]) as NSDictionary?
                    }catch{
                    }
                    file.append((name: fileNames[i], date: self.selectedDirectoryName, modify: (item?.fileCreationDate())!, image: nil))
                }
            }catch{
                fileNames = []
            }
        }
        
        for i in 0..<file.count{
            for j in (i+1..<file.count).reversed(){
                if stringInt(int: file[j-1].name) < stringInt(int: file[j].name){
                    let temp = file[j]
                    file[j] = file[j-1]
                    file[j-1] = temp
                }
            }
        }
        /*/バブルソート・・・
        for i in 0..<file.count{
            for j in (i+1..<file.count).reversed(){
                if file[j-1].modify < file[j].modify{
                    let temp = file[j]
                    file[j] = file[j-1]
                    file[j-1] = temp
                }
            }
        }*/

        //ファイルパスからファイルデータ(写真イメージ)を取ってくる
        if selectedDirectoryName == "All"{
            for i in 0..<file.count{
                let filePath = DocumentPath + "/" + file[i].date + "/" + file[i].name
                file[i].image = UIImage(contentsOfFile:filePath)!
            }
        }else{
            for i in 0..<fileNames.count{
                let fileDirectory = holderDirectory + "/" + file[i].name
                if let image = UIImage(contentsOfFile:fileDirectory){
                    file[i].image = image
                }
            }
        }
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
                cell.thumnailImagre.image = thumbnail
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
    
    var selectImage:UIImage!
    var selectImagePath:String!
    var selectImageDropboxPath:String?
    //var selectFile:(date:String,name:String)
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedDirectoryName == "All"{
            selectImagePath = DocumentPath + "/" + file[indexPath.row].date + "/" + file[indexPath.row].name
            selectImageDropboxPath = "/" + file[indexPath.row].date + "/" + file[indexPath.row].name
        
        }else{
            //選択した写真のパス
            selectImagePath = DocumentPath + "/" + selectedDirectoryName + "/" + file[indexPath.row].name
            selectImageDropboxPath = "/" + selectedDirectoryName + "/" + file[indexPath.row].name
        }
        
        // [indexPath.row] から画像名を探し、UImage を設定
        selectImage = file[indexPath.row].image
        if selectImage != nil {
            // SubViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "selectedImage",sender: nil)
        }
    }
    
    //選択した写真と写真のパス送る
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectedImage"){
            (segue.destination as! SelectedImageViewController).selectedImage = selectImage
            (segue.destination as! SelectedImageViewController).selectedImagePath = selectImagePath
            (segue.destination as! SelectedImageViewController).selectedImageDropboxPath = selectImageDropboxPath
            (segue.destination as! SelectedImageViewController).movedPreview = false
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        loadImage()
        thumbmnailImages = []
        cv.reloadData()
    }
    
    
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cv.delegate = self
        cv.dataSource = self
        
        // Do any additional setup after loading the view.
        let editBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editButtonTapped))
        self.navigationItem.setRightBarButton(editBarButtonItem, animated: true)
        
        
        
    }
    
    //use DropBox
    
    let client = DropboxClientsManager.authorizedClient
    
    var holderName:[String] = []
    var exsistFolderName:[String] = []
    //var exsistDataName:[String] = []
    
 
    

    @IBAction func signin(_ sender: Any) {
        self.checkSignIn()
        
        var dattaName:[String] = []
        
        let _ = client?.files.listFolder(path: "").response { response, error in
            if let error = error {
                // エラーの場合、処理を終了します。
                // 必要ならばエラー処理してください。
                return
            }
            
            guard let respone = response else{
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
            self.detectNewFolder(exsistFolder: dattaName)
            
            print(self.holderName)
            for i in 0..<self.holderName.count{
                self.makeFolder(path: "/" + self.holderName[i])
            }
        }
        
        
    }
    

    
    
    @IBAction func upload(_ sender: Any) {
        self.checkSignIn()
        var dattaName:[String] = []
    
            //dattaName = self.exsistDirectoryData(path: "/" + self.selectedDirectoryName)
        if selectedDirectoryName == "All"{
            holderName = ["Mon1","Mon2","Mon3","Mon4","Mon5","Mon6","Mon0","Tues1","Tues2","Tues3","Tues4","Tues5","Tues6","Tues0","Wednes1","Wednes2","Wednes3","Wednes4","Wednes5","Wednes6","Wednes0","Thurs1","Thurs2","Thurs3","Thurs4","Thurs5","Thurs6","Thurs0","Fri1","Fri2","Fri3","Fri4","Fri5","Fri6","Fri0","Satur","Sun"]
            for j in 0..<holderName.count{
                dattaName = []
                let _ = client?.files.listFolder(path: "/" + holderName[j]).response { response, error in
                    if let error = error {
                        // エラーの場合、処理を終了します。
                        // 必要ならばエラー処理してください。
                        return
                    }
                    
                    guard let respone = response else{
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
                    
                    
                    
                    var detta:[(name:String,date:String,modify:Date,image:UIImage?)] = []
                    
                    for i in 0..<self.file.count{
                        if dattaName.contains(self.file[i].name) != true && self.file[i].date == self.holderName[j]{
                            detta.append(self.file[i])
                        }
                    }

                    for i in 0..<detta.count{
                        let data:Data = detta[i].image!.pngData()!
                        
                        self.client?.files.upload(path: "/" + detta[i].date + "/" + detta[i].name, input: data).response { response, error in
                            if let error = error {
                                // エラーの場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            
                            guard let response = response else {
                                return
                            }
                        }
                    }
                }
            }
        }else{
            let _ = client?.files.listFolder(path: "/" + self.selectedDirectoryName).response { response, error in
                if let error = error {
                    // エラーの場合、処理を終了します。
                    // 必要ならばエラー処理してください。
                    return
                }
                
                guard let respone = response else{
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
                
                
                
                var detta:[(name:String,date:String,modify:Date,image:UIImage?)] = []
                
                for i in 0..<self.file.count{
                    if dattaName.contains(self.file[i].name) != true{
                        detta.append(self.file[i])
                    }
                }
                
                for i in 0..<detta.count{
                    let data:Data = detta[i].image!.pngData()!
                    
                    self.client?.files.upload(path: "/" + detta[i].date + "/" + detta[i].name, input: data).response { response, error in
                        if let error = error {
                            // エラーの場合、処理を終了します。
                            // 必要ならばエラー処理してください。
                            return
                        }
                        
                        guard let response = response else {
                            return
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func download(_ sender: Any) {
        var dattaName:[String] = []
        let fileManager = FileManager.default
        
        if selectedDirectoryName == "All"{
            holderName = ["Mon1","Mon2","Mon3","Mon4","Mon5","Mon6","Mon0","Tues1","Tues2","Tues3","Tues4","Tues5","Tues6","Tues0","Wednes1","Wednes2","Wednes3","Wednes4","Wednes5","Wednes6","Wednes0","Thurs1","Thurs2","Thurs3","Thurs4","Thurs5","Thurs6","Thurs0","Fri1","Fri2","Fri3","Fri4","Fri5","Fri6","Fri0","Satur","Sun"]
            for j in 0..<holderName.count{
                dattaName = []
                let _ = client?.files.listFolder(path: "/" + holderName[j]).response { response, error in
                    if let error = error {
                        // エラーの場合、処理を終了します。
                        // 必要ならばエラー処理してください。
                        return
                    }
                    
                    guard let respone = response else{
                        return
                    }
                    
                    let localFolderDirectory = self.DocumentPath + "/" + self.holderName[j]
                    
                    // エントリー数分繰り返します。
                    // entryオブジェクトからディレクトリ、ファイル情報が取得できます。
                    for entry in (response?.entries)!{
                        // 名前
                        let name = entry.name
                        
                        if fileManager.fileExists(atPath: localFolderDirectory + "/" + name) != true{
                            dattaName.append(name)
                        }
                    }
                    print(dattaName)
                    
                    for i in 0..<dattaName.count{
                        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                            let path = "file://" + localFolderDirectory + "/" + dattaName[i]
                            let directoryURL = NSURL(string: path)! as URL
                            
                            return directoryURL
                        }
                        
                        self.client?.files.download(path: "/" + self.holderName[j] + "/" + dattaName[i], destination: destination).response { response, error in
                            if let error = error {
                                // エラーの場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            
                            guard let response = response else {
                                // レスポンスがない場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            self.loadImage()
                            self.thumbmnailImages = []
                            self.cv.reloadData()
                        }
                    }

                    
                    
                }
            }
        }else{
            
            let _ = client?.files.listFolder(path: "/" + self.selectedDirectoryName).response { response, error in
                if let error = error {
                    // エラーの場合、処理を終了します。
                    // 必要ならばエラー処理してください。
                    return
                }
                
                guard let respone = response else{
                    return
                }
                
                let localFolderDirectory = self.DocumentPath + "/" + self.selectedDirectoryName
                
                // エントリー数分繰り返します。
                // entryオブジェクトからディレクトリ、ファイル情報が取得できます。
                for entry in (response?.entries)!{
                    // 名前
                    let name = entry.name
                    
                    if fileManager.fileExists(atPath: localFolderDirectory + "/" + name) != true{
                        dattaName.append(name)
                    }
                }
                print(dattaName)
                
                for i in 0..<dattaName.count{
                    let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                        let path = "file://" + localFolderDirectory + "/" + dattaName[i]
                        let directoryURL = NSURL(string: path)! as URL
                        
                        return directoryURL
                    }
                    
                    self.client?.files.download(path: "/" + self.selectedDirectoryName + "/" + dattaName[i], destination: destination).response { response, error in
                        if let error = error {
                            // エラーの場合、処理を終了します。
                            // 必要ならばエラー処理してください。
                            return
                        }
                        
                        guard let response = response else {
                            // レスポンスがない場合、処理を終了します。
                            // 必要ならばエラー処理してください。
                            return
                        }
                    }
                    
                    self.loadImage()
                    self.thumbmnailImages = []
                    self.cv.reloadData()
                }
                
                
                
            }
        }
        
        
    }
    
    @objc private func editButtonTapped(){
        let doneBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneButtonTapped))
        self.navigationItem.setRightBarButton(doneBarButtonItem, animated: true)
    }
    
     @objc private func doneButtonTapped(){
        let editBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editButtonTapped))
        self.navigationItem.setRightBarButton(editBarButtonItem, animated: true)
    }
    
   
    
    
    
    @IBAction func syncDropbox(){
        let defaults = UserDefaults.standard
        
        var dropboxFileName:[String] = []
        
        
        if selectedDirectoryName == "All"{
            self.holderName = ["Mon1","Mon2","Mon3","Mon4","Mon5","Mon6","Mon0","Tues1","Tues2","Tues3","Tues4","Tues5","Tues6","Tues0","Wednes1","Wednes2","Wednes3","Wednes4","Wednes5","Wednes6","Wednes0","Thurs1","Thurs2","Thurs3","Thurs4","Thurs5","Thurs6","Thurs0","Fri1","Fri2","Fri3","Fri4","Fri5","Fri6","Fri0","Satur","Sun"]
        }else{
            self.holderName = [selectedDirectoryName]
        }
        for j in 0..<holderName.count{
            
            var directoryLocalData:[String] = defaults.stringArray(forKey: self.holderName[j]) ?? []
            print(holderName[j])
            
            //dropboxのファイル一覧取得
            let _ = client?.files.listFolder(path: "/" + self.holderName[j]).response { response, error in
                if let error = error {
                    // エラーの場合、処理を終了します。
                    // 必要ならばエラー処理してください。
                    return
                }
                
                guard let respone = response else{
                    return
                }
                
                let localFolderDirectory = self.DocumentPath + "/" + self.holderName[j]
                
                // エントリー数分繰り返します。
                // entryオブジェクトからディレクトリ、ファイル情報が取得できます。
                for entry in (response?.entries)!{
                    // 名前
                    let name = entry.name
                    dropboxFileName.append(name)

                }
                
                
                
                //ドロップボックスから削除されたデータをローカルデータも削除
                if directoryLocalData.isEmpty != true {
                    for i in 0..<directoryLocalData.count{
                        if dropboxFileName.contains(directoryLocalData[i]) != true{
                            do {
                                try FileManager.default.removeItem( atPath: localFolderDirectory + "/" + directoryLocalData[i])
                                
                                self.loadImage()
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
                    if dropboxFileName.contains(directoryFile[i].name) != true{
                        uploadData?.append(directoryFile[i])
                        
                    }
                    directoryLocalData.append(directoryFile[i].name)
                }
                
                
                
                //ローカルファイル名保存
                self.userDefaultSave(data: directoryLocalData, path: self.holderName[j])
                
                if uploadData != nil{
                    //upload
                    for i in 0..<uploadData!.count{
                        let data:Data = (uploadData?[i].image!.pngData()!)!
                        
                        self.client?.files.upload(path: "/" + (uploadData?[i].date)! + "/" + (uploadData?[i].name)!, input: data).response { response, error in
                            if let error = error {
                                // エラーの場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            
                            guard let response = response else {
                                return
                            }
                        }
                    }
                }
                
                
                //ローカルファイルになく、ドロップボックスにあるファイル一覧をの名前を取得
                
                var downloadFileName:[String]? = []
                
                for i in 0..<dropboxFileName.count{
                    if self.fileManager.fileExists(atPath: localFolderDirectory + "/" + dropboxFileName[i]) != true{
                        downloadFileName?.append(dropboxFileName[i])
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
                                // エラーの場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            
                            guard let response = response else {
                                // レスポンスがない場合、処理を終了します。
                                // 必要ならばエラー処理してください。
                                return
                            }
                            
                            directoryLocalData.append((downloadFileName?[i])!)
                            self.userDefaultSave(data: directoryLocalData, path: self.holderName[j])
                            
                            self.loadImage()
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
    
}

