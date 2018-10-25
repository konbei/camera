//
//  SelectedImageViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/06.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit
import SwiftyDropbox
import SimpleImageViewer

class SelectedImageViewController:UIViewController,UICollectionViewDataSource,
UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate{
    
  
    
    override func viewWillDisappear(_ animated: Bool) {
          self.navigationController?.isNavigationBarHidden = false
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell:CustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for:indexPath )as! CustomCell

            let frame = view.frame.width
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
        let height: CGFloat = view.bounds.height//view.bounds.height - collectionView.frame.height //- editBar.frame.height //- topbar.frame.height// + editBar.frame.height
        return CGSize(width: width, height: height)
    }

    var safes:CGFloat = 0.0
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        print(self.view.safeAreaInsets)
        
        if safes == 0.0{
            safe = self.view.safeAreaInsets.top
            safes = safe
        }
        
        if safes == 0.0{
            safe = self.view.safeAreaInsets.left
            safes = safe
        }
        
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
    
    page = Int(ceil(CollectionView.contentOffset.x/self.view.bounds.width))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            self.CollectionView.collectionViewLayout.invalidateLayout()
            let ax = self.file!.count
            self.CollectionView.contentSize.width = (self.view.frame.width ) * CGFloat(ax)
            self.CollectionView.contentSize.height = self.view.frame.height
            //navigationcontrollerからの遷移じゃない場合navigationbarの分詰める
            if movedPreview{
                if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight{
                    //ベゼルディスプレイか判定
                    if view.safeAreaInsets.bottom == 0{
                        safe = 0
                    }else{
                        safe = safes
                    }
                    if page == 0{
     
                        
                        self.CollectionView.setContentOffset(CGPoint(x:+self.view.safeAreaInsets.left, y: 0), animated: false)
                    }else{
                        self.CollectionView.setContentOffset(CGPoint(x: (self.view.frame.width)  * CGFloat(self.page) + safe  , y: 0.0), animated: false)
                    }
                }else{
     

                    if view.safeAreaInsets.bottom == 0{
                        safe = 0
                    }else{
                        safe = -safes
                    }
                    
                    self.CollectionView.setContentOffset(CGPoint(x: (self.view.frame.width)  * CGFloat(self.page) + safe  , y: 0.0), animated: false)
                }
            }else{
                self.CollectionView.setContentOffset(CGPoint(x: (self.view.frame.width)  * CGFloat(self.page), y: 0.0), animated: false)
            }
        }
    }
    
    @IBOutlet weak var viewrTitle: UINavigationItem!
    @IBOutlet weak var buckComeraBar: UINavigationBar!
    
    @IBOutlet weak var safeAreaColor: UINavigationBar!
    @IBOutlet weak var topbar: UINavigationBar!
    @IBOutlet weak var editBar: UINavigationBar!
    
    @IBAction func buck(_ sender: Any) {
        if self.movedPreview == true{
            self.performSegue(withIdentifier: "comeCamera", sender: self)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    var deleteImage = false
    //プレビュー画面かどうか
    var movedPreview:Bool!
    //選択した写真と写真のパス得る
    var selectedDirectory:String!
    var selectedImage:UIImage!
    var selectedImagePath:String!
    var selectedImageDropboxPath:String?
    var file:[(name:String,date:String,modify:Date,image:UIImage?)]!
    var selectRow:Int!



    @IBAction func swip(_ sender: UIPinchGestureRecognizer) {
        let visiblecell = CollectionView.visibleCells.first
        let indexPath = CollectionView.indexPath(for: visiblecell!)
        let cell = CollectionView.cellForItem(at: indexPath!) as! CustomCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cell.img
        }
        
        present(ImageViewerController(configuration: configuration), animated: true)
        
    }
    var swiep = UIPinchGestureRecognizer()
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    var safe:CGFloat = 0.0
    let util = Util()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        file = util.loadImage(selectedDirectoryName: self.selectedDirectory)
        //CollectionView.reloadData()
        page = self.selectRow

        
        
        CollectionView.delegate = self
        CollectionView.dataSource = self
        
        self.swiep = UIPinchGestureRecognizer(target: self, action: #selector(swip))
        self.swiep.delegate = self
        self.CollectionView.addGestureRecognizer(self.swiep)
        
        //controllerbarは非表示
        self.viewrTitle.title = self.selectedDirectory
        self.navigationController?.isNavigationBarHidden = true
        
        

    }
    
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        editBar.isHidden = !editBar.isHidden
        topbar.isHidden = !topbar.isHidden
        safeAreaColor.isHidden = !safeAreaColor.isHidden
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return  true
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
                    try FileManager.default.removeItem( atPath: self.util.documentPath + "/" + (self.file?[index].date)! + "/" + (self.file?[index].name)! )
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
                let defaults = UserDefaults.standard
                if self.file.count > 1 && index == 0{
                    defaults.set(self.file[1].image!.reSizeImage(reSize: CGSize(width: 80, height: 80)).pngData(), forKey: "thumbnailImage")
                    
                    defaults.synchronize()
                }else if index == 0{
                    defaults.set(UIImage(named: "noImage")!.pngData(), forKey: "thumbnailImage")
                    defaults.synchronize()
                }
                self.performSegue(withIdentifier: "comeCamera", sender: self)
            }else{
                self.navigationController?.popViewController(animated: true)
 
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
