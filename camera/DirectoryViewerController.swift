//
//  DirectoryViewerController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/03.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit

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
            fileImages.append(UIImage(contentsOfFile:fileDirectory)!)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // "Cell" はストーリーボードで設定したセルのID
        let cell:UICollectionViewCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                               for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        if (2*indexPath.section + indexPath.row) < fileImages.count{
            let cellImage = fileImages[2*indexPath.section + indexPath.row]
        
            imageView.image = cellImage
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        // section数は１つ
        if Int(ceil(Double(fileImages.count / 2))) != 0{
            return Int(ceil(Double(fileImages.count) / 2.0))
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        
        return 2
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
