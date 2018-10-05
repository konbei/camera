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
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, true, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}


class DirectoryViewerController: UIViewController,UICollectionViewDataSource,
UICollectionViewDelegate {
    
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
            fileImages.append( UIImage(contentsOfFile:fileDirectory)!)
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
            thumbnail = cellImage.resize(size: CGSize(width: 81, height: 81))
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
    
    override func viewWillAppear(_ animated: Bool) {
        loadImage()
        cv.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cv.delegate = self
        cv.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

