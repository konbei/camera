//
//  SelectedImageViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/06.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit


class SelectedImageViewController: UIViewController {
    
    //ImageViewをタップした時barの表示/非表示変更
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        editBar.isHidden = !editBar.isHidden
        self.navigationController?.isNavigationBarHidden = !(self.navigationController?.isNavigationBarHidden)!
    }
    
    @IBOutlet weak var editBar: UINavigationBar!
    
    @IBOutlet weak var imageView: UIImageView!
    
    //選択した写真と写真のパス得る
    var selectedImage:UIImage!
    var selectedImagePath:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //最初barは非表示
        editBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
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
                } catch {
                    //エラー処理
                    print("error")
                }
               self.navigationController?.popViewController(animated: true)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
