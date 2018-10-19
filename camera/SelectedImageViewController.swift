//
//  SelectedImageViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/06.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit
import SwiftyDropbox


class SelectedImageViewController:UIViewController,UICollectionViewDataSource,
UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    private let documentPath = NSHomeDirectory() + "/Documents"
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell:CustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath )as! CustomCell
            let frame = view.frame.width + 10
            var thumbnail:UIImage? = nil
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "imageSetting",attributes: .concurrent)
            group.enter()
            queue.async(group: group) {
                //サムネイル作成方法変更
                thumbnail = self.resize(image: (self.file?[indexPath.row].image)!, width: Double(frame))
                group.leave()
            }
            group.notify(queue: .main){
                cell.img.image = thumbnail
        }
            return cell
    }
    
  
    
    
    
    @IBOutlet weak var CollectionView: UICollectionView!
    

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.file?.count)!
    }
    
  //  var mainScrollView: UIScrollView!
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.width
        let height: CGFloat = view.bounds.height + editBar.frame.height
        return CGSize(width: width, height: height)
    }
    //ImageViewをタップした時barの表示/非表示変更
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        if movedPreview == true{
            buckComeraBar.isHidden = !buckComeraBar.isHidden
        }
        editBar.isHidden = !editBar.isHidden
        self.navigationController?.isNavigationBarHidden = !(self.navigationController?.isNavigationBarHidden)!
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.CollectionView.collectionViewLayout.invalidateLayout()
            let ax = self.file!.count
            self.CollectionView.contentSize.width = self.view.frame.width * CGFloat(ax)
            if self.page != 0{
                self.CollectionView.setContentOffset(CGPoint(x: self.view.frame.width  * CGFloat(self.page) , y: 0.0), animated: false)
            }
            
        }
        
    }
    
    var page:Int = 0
   override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    page = Int(floor(CollectionView.contentOffset.x/self.view.bounds.width))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if UIDevice.current.userInterfaceIdiom == .phone{
            self.CollectionView.collectionViewLayout.invalidateLayout()
            let ax = self.file!.count
            self.CollectionView.contentSize.width = self.view.frame.width * CGFloat(ax)
            if self.page != 0{
                self.CollectionView.setContentOffset(CGPoint(x: self.view.frame.width  * CGFloat(self.page) , y: 0.0), animated: false)
            }
            
        }
    }
    
    @IBOutlet weak var buckComeraBar: UINavigationBar!
    
    @IBOutlet weak var topbar: UINavigationBar!
    @IBOutlet weak var editBar: UINavigationBar!
    
    @IBAction func buck(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBOutlet weak var imageView: UIImageView!

    var deleteImage = false
    //プレビュー画面かどうか
    var movedPreview = false
    //選択した写真と写真のパス得る
    var selectedImage:UIImage!
    var selectedImagePath:String!
    var selectedImageDropboxPath:String?
    var file:[(name:String,date:String,modify:Date,image:UIImage?)]?
    
     let C_IMAGEVIEW_TAG = 1000;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionView.delegate = self
        CollectionView.dataSource = self
        
        //最初barは非表示
   // editBar.isHidden = true
    self.navigationController?.isNavigationBarHidden = true
    buckComeraBar.isHidden = true
      //self.navigationController.
    }
    
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        editBar.isHidden = !editBar.isHidden
        topbar.isHidden = !topbar.isHidden
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    //画像シェア機能
    @IBAction func shareAction(_ sender: Any) {
        let index = Int(self.CollectionView.contentOffset.x/self.view.bounds.width)
        let activities = [self.file?[index].image!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: self.view.bounds.height, width: 1.0, height: 1.0)
 
        self.present(activityViewController,animated: true,completion: nil)
    }
    
    //画像削除機能
    @IBAction func DeleteImage(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "写真削除", message: "写真を削除してもいいですか？", preferredStyle:  UIAlertController.Style.alert)
        

        // 削除ボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            
            // ファイル削除
            (action: UIAlertAction!) -> Void in
                let index = Int(self.CollectionView.contentOffset.x/self.view.bounds.width)
                do {
                    try FileManager.default.removeItem( atPath: self.documentPath + "/" + (self.file?[index].date)! + "/" + (self.file?[index].name)! )
                    self.deleteImage = true
                } catch {
                    //エラー処理
                    print("error")
                }
            
            guard let client = DropboxClientsManager.authorizedClient else {
                return
            }
            
            client.files.deleteV2(path: "/" + (self.file?[index].date)! + "/" + (self.file?[index].name)!).response { (result: Files.DeleteResult?, error: CallError<Files.DeleteError>?) in
                if let error = error {
                    // エラーの場合、処理を終了します。
                    // 必要ならばエラー処理してください。
                    print("dropboxには無いよ〜")
                    return
                }
                
                // 正常終了の場合の処理を記述してください。
            }
            
            if self.movedPreview == true{
                self.performSegue(withIdentifier: "comeCamera", sender: self)
            }else{
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.isNavigationBarHidden = false
            }
            
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
           
            (action: UIAlertAction!) -> Void in
            
        })
        
        //  UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "comeCamera" && deleteImage == true){
            (segue.destination as! CameraViewController).thumbnailImage.image = nil
            deleteImage = false
        }
    }
    
    func resize(image: UIImage, width: Double) -> UIImage {
        
        // オリジナル画像のサイズからアスペクト比を計算
        let aspectScale = image.size.height / image.size.width
        
        // widthからアスペクト比を元にリサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectScale))
        
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    
  
}

extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        print("touchesBegan")
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
        print("touchesMoved")
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesEnded(touches, with: event)
        print("touchesEnded")
    }
    
}
class CustomCell: UICollectionViewCell {
    @IBOutlet var img:UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
}
