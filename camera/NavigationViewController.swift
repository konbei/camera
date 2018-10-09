//
//  NavigationViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/09.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    //継承したシーンごとに画面の向きを設定するように変更
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let vc = self.viewControllers.last else {
            return .all
        }
        return vc.supportedInterfaceOrientations
    }
    
    override var shouldAutorotate: Bool {
        guard let vc = self.viewControllers.last else {
            return true
        }
        return vc.shouldAutorotate
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
