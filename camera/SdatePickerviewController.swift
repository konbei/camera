//
//  SdatePickerviewController.swift
//  camera
//
//  Created by 中西航平 on 2018/09/25.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit




class SdatePickerviewController: UIViewController, UINavigationControllerDelegate {
    
    var selctedsection:Int = 0
    var selectedrow:Int = 0
   
    
    
    @IBOutlet weak var Picker: UIDatePicker!
    
    //画面遷移
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let controller = viewController as? ClassTimeSettingViewController {
            let format2 = DateFormatter()
            format2.dateFormat = "Hmm"
            let StringTime = format2.string(from: Picker.date)
            let time = Int(StringTime)
            //開始時刻の行をタップした時
            if selectedrow == 0 {
                controller.startClassTime[selctedsection] = time!
            }else{
                controller.finishClassTime[selctedsection] = time!
            }
            controller.Save()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self        /*
        inputDatePicker.datePickerMode = UIDatePicker.Mode.time
        inputDatePicker.locale = Locale.current
        self.view.addSubview(inputDatePicker)
         */
        // Do any additional setup after loading the view.
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
