//
//  JViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/09/23.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit

class JViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    //時限ボタン
    @IBOutlet weak var one_class: UIButton!
    
    @IBOutlet weak var cv: UICollectionView!
    
   
    
    //コレクションセル作成
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell:CustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! CustomCell
        //cell.lblSample.text = "ラベル\(indexPath.row)"
    
        return cell
    }
    
    // コレクションセクションの数（今回は1つだけです）
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 7//時限数
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return 5; //曜日数
    }
    
  

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        //セクション間の余白設定(bottom下)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        cv.collectionViewLayout = layout
     
       
    }
        // Do any additional setup after loading the view.
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
