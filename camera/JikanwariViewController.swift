//
//  JViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/09/23.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit
import CoreData
//時限ごとの名前
class JikanwariViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
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
    
    // 授業一覧
    private var classes: [SettingsData2]?
    
    //曜日と時限数
    var daycounts = 5
    var classcounts = 6
    
    //数字に対応する曜日のStringを返す
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
        default:
            return ""
        }
        
    }
    
    @IBOutlet weak var cv: UICollectionView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
        self.classes = ClassDataManager().fetchAllClasses()
        // 再読み込みする
        cv.reloadData()
    }
    
    //コレクションセル作成
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        let nameDay = self.numberday(num: indexPath.row)
        let period = String(indexPath.section + 1)
        
        // 特定の曜日、時限に当てはまる授業を探し出す
        let matchedClass = self.classes?.first { $0.nameday == nameDay && $0.nameclass == period }
        label.text = matchedClass?.classname ?? ""
        
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
    
    //タップされたセルのindexからディレクトリの名前を取得してビュワーに遷移
    var directoryName = ""
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section != 6){
            directoryName = numberday(num: indexPath.row) + "\(indexPath.section+1)"
            
        }else{
            directoryName = numberday(num: indexPath.row) + "0"
        }
        performSegue(withIdentifier: "directoryViewr", sender: nil)
    }
    
    //全部表示ボタン
    @IBAction func allButton(_ sender: Any) {
        directoryName = "All"
        performSegue(withIdentifier: "directoryViewr", sender: nil)
    }
    
    @IBAction func SaturdayButtun(_ sender: Any) {
        directoryName = "Satur"
        performSegue(withIdentifier: "directoryViewr", sender: nil)
    }
    
    @IBAction func SundayButtun(_ sender: Any) {
        directoryName = "Sun"
        performSegue(withIdentifier: "directoryViewr", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "directoryViewr"){
            (segue.destination as! DirectoryViewerController).selectedDirectoryName = directoryName
        }
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
