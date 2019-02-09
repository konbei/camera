//
//  UseWebViewController.swift
//  
//
//  Created by 中西航平 on 2019/02/04.
//

import UIKit
import WebKit
class UseWebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let embedHTML = "<html><head><meta name=\"viewport\" content=\"width=device, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes\"/></head><body><div><iframe width=\"device\" height=\"315\" src=\"https://www.youtube.com/embed/SC_7pedG22E\" frameborder=\"0\" gesture=\"media\" allow=\"encrypted-media\" allowfullscreen></iframe></div></body></html>"
        let url = URL(string: "https://")
        webView.loadHTMLString(embedHTML, baseURL: url)
        webView.contentMode = UIView.ContentMode.scaleAspectFit
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
