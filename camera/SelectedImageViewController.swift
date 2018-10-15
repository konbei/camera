//
//  SelectedImageViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/06.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit
import SwiftyDropbox


class SelectedImageViewController: UIViewController {
    
    
    
    //ImageViewをタップした時barの表示/非表示変更
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        if movedPreview == true{
            buckComeraBar.isHidden = !buckComeraBar.isHidden
        }
        editBar.isHidden = !editBar.isHidden
        self.navigationController?.isNavigationBarHidden = !(self.navigationController?.isNavigationBarHidden)!
    }
    

        
    @IBOutlet weak var buckComeraBar: UINavigationBar!
    
    @IBOutlet weak var editBar: UINavigationBar!
    
    @IBOutlet weak var imageView: UIImageView!

    var deleteImage = false
    //プレビュー画面かどうか
    var movedPreview = false
    //選択した写真と写真のパス得る
    var selectedImage:UIImage!
    var selectedImagePath:String!
    var selectedImageDropboxPath:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //最初barは非表示
        editBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        buckComeraBar.isHidden = true
        
        imageView.image = selectedImage

        imageView.contentMode =  UIView.ContentMode.scaleAspectFit
        
        
        //self.navigationController?.hidesBarsOnTap = true
      
        // Do any additional setup after loading the view.
    }
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    //画像シェア機能
    @IBAction func shareAction(_ sender: Any) {
        let activities = [selectedImage] as [Any]
        let activityViewController = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        self.present(activityViewController,animated: true,completion: nil)
    }
    
    //画像削除機能
    @IBAction func DeleteImage(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "写真削除", message: "写真を削除してもいいですか？", preferredStyle:  UIAlertController.Style.alert)
        

        // 削除ボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            // ファイル削除
            (action: UIAlertAction!) -> Void in
                do {
                    try FileManager.default.removeItem( atPath: self.selectedImagePath )
                    self.deleteImage = true
                } catch {
                    //エラー処理
                    print("error")
                }
            
            guard let client = DropboxClientsManager.authorizedClient else {
                return
            }
            
            client.files.deleteV2(path: self.selectedImageDropboxPath!).response { (result: Files.DeleteResult?, error: CallError<Files.DeleteError>?) in
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
}
