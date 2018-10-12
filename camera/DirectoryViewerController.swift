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
    
    var file:[(name:String,date:String,modify:Date,image:UIImage?)]!
    
     //タップされた授業の曜日と時間を取ってくる
    var selectedDirectoryName = ""
    private var fileNames:[String] = []
    private var fileImages:[UIImage] = []
    private let DocumentPath = NSHomeDirectory() + "/Documents"
    
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
    
    let fileManager = FileManager.default
    
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
                            file.append((name: fileNames[i], date: numberday(num:day), modify: (item?.fileModificationDate())!, image: nil))
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
                                file.append((name: fileNames[i], date: numberday(num:day) + "\(classes)", modify: (item?.fileModificationDate())!, image: nil))
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
                    file.append((name: fileNames[i], date: self.selectedDirectoryName, modify: (item?.fileModificationDate())!, image: nil))
                }
            }catch{
                fileNames = []
            }
        }
        
        //バブルソート・・・
        for i in 0..<file.count{
            for j in (i+1..<file.count).reversed(){
                if file[j-1].modify < file[j].modify{
                    let temp = file[j]
                    file[j] = file[j-1]
                    file[j-1] = temp
                }
            }
        }

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
    //var selectFile:(date:String,name:String)
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedDirectoryName == "All"{
            selectImagePath = DocumentPath + "/" + file[indexPath.row].date + "/" + file[indexPath.row].name
        
        }else{
            //選択した写真のパス
            selectImagePath = DocumentPath + "/" + selectedDirectoryName + "/" + file[indexPath.row].name
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
            (segue.destination as! SelectedImageViewController).movedPreview = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        file = []
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

