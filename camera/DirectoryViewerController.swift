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
    
    
     //タップされた授業の曜日と時間を取ってくる
    var selectedDirectoryName = ""
    private var fileNames:[String] = []
    private var fileImages:[UIImage] = []
    private let DocumentPath = NSHomeDirectory() + "/Documents"
    
    //タップされた授業の写真を取ってくる
    func loadImage(){
        let holderDirectory = DocumentPath + "/" + selectedDirectoryName
        fileNames = []
        fileImages = []
        //ディレクトリからファイルの名前を取ってくる
        do{
            try fileNames = FileManager.default.contentsOfDirectory(atPath: holderDirectory)
        }catch{
            fileNames = []
        }
        //ファイルパスからファイルデータ(写真イメージ)を取ってくる
        if fileNames.count != 0{
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
        return fileNames.count
    }
    
    var selectImage:UIImage!
    var selectImagePath:String!
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //選択した写真のパス
        selectImagePath = DocumentPath + "/" + selectedDirectoryName + "/" + fileNames[indexPath.row]
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

