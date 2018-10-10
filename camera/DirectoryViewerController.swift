//
//  DirectoryViewerController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/03.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit

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
    
    var file:[(name:String,date:String)]!
    
     //タップされた授業の曜日と時間を取ってくる
    var selectedDirectoryName = ""
    private var fileNames:[String] = []
    private var fileImages:[UIImage] = []
    private let DocumentPath = NSHomeDirectory() + "/Documents"
    
    private var daycounts = 5
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
        default:
            return ""
        }
        
    }
    
    let fileManager = FileManager.default
    
    func stringInt(int:String)->Int{
        let splitNumbers = (int.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
        let number = splitNumbers.joined()
        return Int(number)!
    }
    
    //タップされた授業の写真を取ってくる
    func loadImage(){
        var holderDirectory:String!
        if selectedDirectoryName == "All"{
             holderDirectory = DocumentPath
        }else{
             holderDirectory = DocumentPath + "/" + selectedDirectoryName
        }
        
        fileNames = []
        fileImages = []
        file = []
        
        //ディレクトリからファイルの名前を取ってくる
        if selectedDirectoryName == "All"{
            for day in 0..<daycounts{
                for classes in 0...classcounts{
                    let directoryPath = DocumentPath + "/" + numberday(num: day) + "\(classes)"
                    do{
                        try fileNames = FileManager.default.contentsOfDirectory(atPath: directoryPath)
                        if fileNames.count != 0{
                            for i in 0..<fileNames.count{
                                file.append((name: fileNames[i], date: numberday(num: day) + "\(classes)"))
                            }
                        }
                    }catch{
                    }
                }
            }
        }else{
            do{
                try fileNames = FileManager.default.contentsOfDirectory(atPath: holderDirectory)
            }catch{
                fileNames = []
            }
        }
        
      
        
        //バブルソート・・・
        if selectedDirectoryName == "All"{
            for i in 0..<file.count{
                for j in (i+1..<file.count).reversed(){
                    if stringInt(int: file[j-1].name) < stringInt(int: file[j].name){
                        let temp = file[j]
                        file[j] = file[j-1]
                        file[j-1] = temp
                    }
                }
            }
        }else{
            for i in 0..<fileNames.count{
                for j in (i+1..<fileNames.count).reversed(){
                    if stringInt(int: fileNames[j-1]) < stringInt(int: fileNames[j]){
                        let temp = fileNames[j]
                        fileNames[j] = fileNames[j-1]
                        fileNames[j-1] = temp
                    }
                }
            }
        }
        
        
        
        
        //ファイルパスからファイルデータ(写真イメージ)を取ってくる

        if selectedDirectoryName == "All"{
            for i in 0..<file.count{
                let filePath = DocumentPath + "/" + file[i].date + "/" + file[i].name
                fileImages.append(UIImage(contentsOfFile:filePath)!)
            }
        }else{
            for i in 0..<fileNames.count{
                let fileDirectory = holderDirectory + "/" + fileNames[i]
                fileImages.append(UIImage(contentsOfFile:fileDirectory)!)
            }
        }
       
      
    }
    
                

    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        //セルのクラス作ってそこでスクロールした時の初期化実装してます
        let cell:DirectoryViewrCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath) as! DirectoryViewrCell

       
        let cellImage = self.fileImages[indexPath.row]
        var thumbnail:UIImage? = nil
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "imageSetting",attributes: .concurrent)
        group.enter()
        queue.async(group: group) {
            //サムネイル作成方法変更
            thumbnail = cellImage.reSizeImage(reSize:CGSize(width: 81, height: 81))
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
        return fileImages.count
    }
    
    var selectImage:UIImage!
    var selectImagePath:String!
    //var selectFile:(date:String,name:String)
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedDirectoryName == "All"{
            selectImagePath = DocumentPath + "/" + file[indexPath.row].date + "/" + file[indexPath.row].name
            print(selectImagePath)
        }else{
            //選択した写真のパス
            selectImagePath = DocumentPath + "/" + selectedDirectoryName + "/" + fileNames[indexPath.row]
        }
        
        // [indexPath.row] から画像名を探し、UImage を設定
        selectImage = fileImages[indexPath.row]
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
    }
    




}

