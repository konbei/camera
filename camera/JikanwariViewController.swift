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
class JikanwariViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // ステータスバーの文字色を白で指定
        return .lightContent
    }
    
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
    let util = Util()
   
    
    @IBOutlet weak var cv: UICollectionView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.navigationController)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "1F9956")
       
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.classes = ClassDataManager().fetchAllClasses()
       // cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        cv.reloadData()
        self.cv.delegate = self
        self.cv.dataSource = self
        // CoreDataからデータをfetchしてくる
       
        //cv.reloadData()
        
    }
    
    var safeAreaHeight:CGFloat!
    var safeAreaWidth:CGFloat!
    var cellWidth:CGFloat!
    var cellHight:CGFloat!
    var spaceWidth:CGFloat!
    var spaceHight:CGFloat!
    var miniWidth:CGFloat!
    var miniHeight:CGFloat!
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        safeAreaHeight = self.view.frame.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom  -  UIApplication.shared.statusBarFrame.height
        
        safeAreaWidth = self.view.bounds.width //- self.view.safeAreaInsets.left - self.additionalSafeAreaInsets.right
        
        cellWidth = safeAreaWidth / 6
        cellHight = safeAreaHeight / 8
        miniWidth = cellWidth / 3
        miniHeight = miniWidth
        spaceWidth = ((cellWidth / 3) * 2) / 6
        spaceHight = (cellHight - miniHeight) / 8
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spaceHight, left: 0, bottom: 0, right: 0)
  
        layout.minimumInteritemSpacing = spaceWidth
        print(layout.sectionInset)
        cv.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
     //cellのサイズを動的に設定
     if indexPath.row == 0 && indexPath.section == 0{
     return CGSize(width: miniWidth, height: miniHeight)
     }else if indexPath.section == 0{
     return CGSize(width: cellWidth, height: miniHeight)
     }else if indexPath.row == 0{
     return CGSize(width: miniWidth, height: cellHight )
     }else{
     return CGSize(width: cellWidth, height: cellHight)
     }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "directoryViewr"){
            print(directoryName)
            (segue.destination as! DirectoryViewerController).selectedDirectoryName = directoryName
        }
    }
    
    //コレクションセル作成
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        
        
       
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.adjustsFontSizeToFitWidth = true
       
       
        if indexPath.row == 0 && indexPath.section == 0{
            label.font = UIFont(name: "Title 3", size: 40)
            cell.backgroundColor = UIColor.clear
            label.backgroundColor = UIColor.clear
        }else if indexPath.row == 0{
            label.adjustsFontSizeToFitWidth = false
            label.font = UIFont(name: "Title 3", size: miniWidth-6)

           // label.font = UIFont.systemFont(ofSize: miniWidth-6)
 
            label.numberOfLines = 0
            if indexPath.section != 7{
            label.text = "\(indexPath.section)"
            }else{
            label.text = "他"
            }
        }else if indexPath.section == 0{
            label.font = UIFont(name: "Title 3", size: 40)
            label.text = "\(self.util.numberday(num: indexPath.row-1))"
        }else{
            label.font = UIFont(name: "Title 3", size: 40)
            let nameDay = self.util.numberday(num: indexPath.row - 1)
            var period:String = ""
            if indexPath.section == 7{
                period = "0"
            }else{
                period = String(indexPath.section)
            }
            if label.backgroundColor == UIColor.clear{
                label.backgroundColor = UIColor(hex: "1F9956")
                cell.backgroundColor = UIColor(hex: "C15320")
            }
            // 特定の曜日、時限に当てはまる授業を探し出す
            let matchedClass = self.classes?.first { $0.nameday == nameDay && $0.nameclass == period }
           label.text = matchedClass?.classname ?? ""
        }

        return cell
    }
    
    // コレクションセクションの数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 8//時限数 + 次元
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return 6 //曜日数 + 曜日欄
    }
    
    //タップされたセルのindexからディレクトリの名前を取得してビュワーに遷移
    var directoryName = ""
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section != 0 && indexPath.row != 0{
            if(indexPath.section != 7){
                directoryName = self.util.numberday(num: indexPath.row-1) + "\(indexPath.section)"
                
            }else{
                directoryName = self.util.numberday(num: indexPath.row-1) + "0"
            }
            performSegue(withIdentifier: "directoryViewr", sender: nil)
        }
    }
}

class JikanCell:UICollectionViewCell{
    @IBOutlet weak var label: UILabel!
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    open override func prepareForReuse() {
        super.prepareForReuse()
        label = nil
        
    }
    
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = hex.map { String($0) } + Array(repeating: "0", count: max(6 - hex.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0) / 255.0
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0) / 255.0
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}
