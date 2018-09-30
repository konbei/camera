//
//  JViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/09/23.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit

//時限ごとの名前
var oneClassData = ["","","","",""]
var twoClassData = ["","","","",""]
var treeClassData = ["","","","",""]
var fourClassData = ["","","","",""]
var fiveClassData = ["","","","",""]
var sixClassData = ["","","","",""]
var zeroClassData = ["","","","",""]
var classTimeName = [oneClassData,twoClassData,treeClassData,fourClassData,fiveClassData,sixClassData]


//曜日ごとの名前データを時限ごとの名前データに変換
func convertNameData(){
    oneClassData = [MonClassName[0],TuesClassName[0],WedClassName[0],ThursClassName[0],FriClassName[0]]
    twoClassData = [MonClassName[1],TuesClassName[1],WedClassName[1],ThursClassName[1],FriClassName[1]]
    treeClassData = [MonClassName[2],TuesClassName[2],WedClassName[2],ThursClassName[2],FriClassName[2]]
    fourClassData = [MonClassName[3],TuesClassName[3],WedClassName[3],ThursClassName[3],FriClassName[3]]
    fiveClassData = [MonClassName[4],TuesClassName[4],WedClassName[4],ThursClassName[4],FriClassName[4]]
    sixClassData = [MonClassName[5],TuesClassName[5],WedClassName[5],ThursClassName[5],FriClassName[5]]
    classTimeName = [oneClassData,twoClassData,treeClassData,fourClassData,fiveClassData,sixClassData,zeroClassData]
}

class JikanwariViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var cv: UICollectionView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
        getData()
        // 再読み込みする
       cv.reloadData()
    }
    
    //コレクションセル作成
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
         convertNameData()
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.text = classTimeName[indexPath.section][indexPath.row]
        print(label.text!)
        
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
