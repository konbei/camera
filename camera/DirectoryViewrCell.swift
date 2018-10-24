//
//  DirectoryViewrCellCollectionViewCell.swift
//  camera
//
//  Created by 中西航平 on 2018/10/04.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit

class DirectoryViewrCell: UICollectionViewCell {
    var backView:UIView?
    var testView : UIView?

    @IBOutlet weak var img: UIImageView!
    
    //セルが再利用される時呼ばれる、このタイミングで初期化する
    override func prepareForReuse() {
        super.prepareForReuse()
  
    }
    
}
