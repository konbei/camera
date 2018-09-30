//
//  ClassNameTableCell.swift
//  camera
//
//  Created by 中西航平 on 2018/09/27.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit

protocol TextEditedDelegate {
    func textFieldDidEndEditing(cell:ClassNameTableCell, value:String)
}
class ClassNameTableCell: UITableViewCell,UITextFieldDelegate
{
    
    var delegate:TextEditedDelegate! = nil
    
    
    //自作セル(.xib)のitem
    @IBOutlet weak var ClassNumber: UILabel!
    @IBOutlet weak var ClassNameText: UITextField!
    
    //nibファイルがアプリケーションに読み込まれ、nibファイルに登録されたのオブジェクト間のインスタンス変数(IBOutlet)の自動接続が終了すると送信されるメッセージ
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
    }
    
    //主にビューのフレームが変更された時に呼ばれる
    override func layoutSubviews() {
        super.layoutSubviews()
        ClassNameText.delegate = self   //textfieldからデリゲート
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //returnキーを押した後の動作
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //キーボードを閉じる。
        textField.resignFirstResponder()
        return true
    }
    
    //returnキー押した後の動作(shouldreturnの後に呼ばれる)
    func textFieldDidEndEditing(_ textField: UITextField) {
        //ClassNameCell.deregate = selfされたクラスにtextFieldDidEnding実行されたとを通知
                                            //   のtextFieldDidEnding実行
        self.delegate.textFieldDidEndEditing(cell: self, value:textField.text!)
    }
}
