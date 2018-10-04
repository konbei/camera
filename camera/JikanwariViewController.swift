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
    //曜日ごとの授業名称
    private var MonClassName:[String] = []
    private var TuesClassName:[String] = []
    private var WedClassName:[String] = []
    private var ThursClassName:[String] = []
    private var FriClassName:[String] = []
    
    //時間ごとの授業名称
    private var oneClassData:[String] = []
    private var twoClassData:[String] = []
    private var treeClassData:[String] = []
    private var fourClassData:[String] = []
    private var fiveClassData:[String] = []
    private var sixClassData:[String] = []
    private var zeroClassData:[String] = []
    private var classTimeName:[[String]] = []
    
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
    
    func getNameData() {
        for day in 0..<daycounts{
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<SettingsData2> = SettingsData2.fetchRequest()
            let predicate = NSPredicate(format:"%K = %@","nameday",numberday(num: day)) //指定した曜日の名前データを取ってくる
            fetchRequest.predicate = predicate
            
            let SettingsData = try! context.fetch(fetchRequest)
            //曜日ごとの名前データを取得
            if(!SettingsData.isEmpty){
                for i in 0..<SettingsData.count{
                    switch day{
                    case 0:
                        MonClassName[i] = SettingsData[i].classname!
                        
                    case 1:
                        TuesClassName[i] = SettingsData[i].classname!
                        
                    case 2:
                        WedClassName[i] = SettingsData[i].classname!
                        
                    case 3:
                        ThursClassName[i] = SettingsData[i].classname!
                        
                    case 4:
                        FriClassName[i] = SettingsData[i].classname!
                        
                    default:
                        break
                    }
                    
                    do{
                        try context.save()
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
    @IBOutlet weak var cv: UICollectionView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
        getNameData()
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "directoryViewr"){
            (segue.destination as! DirectoryViewerController).selectedDirectoryName = directoryName
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MonClassName = ["","","","","",""]
        TuesClassName = ["","","","","",""]
        WedClassName = ["","","","","",""]
        ThursClassName = ["","","","","",""]
        FriClassName = ["","","","","",""]
        
        oneClassData = ["","","","",""]
        twoClassData = ["","","","",""]
        treeClassData = ["","","","",""]
        fourClassData = ["","","","",""]
        fiveClassData = ["","","","",""]
        sixClassData = ["","","","",""]
        zeroClassData = ["","","","",""]
        classTimeName = [oneClassData,twoClassData,treeClassData,fourClassData,fiveClassData,sixClassData]
        
        
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
