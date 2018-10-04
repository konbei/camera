//
//  ExtensionViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/02.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import Photos

// デリゲート部分を拡張する
extension CameraViewController:AVCapturePhotoCaptureDelegate {
    
    // 映像をキャプチャする
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Dataを取り出す
        guard let photoData = photo.fileDataRepresentation() else {
            return
        }
        // Dataから写真イメージを作る
        if let stillImage = UIImage(data: photoData) {
            // ディレクトリに写真を保存する
            saveImage(image: stillImage)
        }
    }
    
    func saveImage(image: UIImage){
        //現在の年日付曜日時間得る
        let now = Date()
        
        //曜日の出力
        let comp = Calendar.Component.weekday
        let weeks = ["Sun","Mon","Tues","Wednes","Thurs","Fri","Satur"]
        let weekIdx = NSCalendar.current.component(comp, from:now)// 1 (1 ~ 7までの数値で日曜日〜月曜日を返す)
         let week = weeks[weekIdx - 1] // 日曜 (0が日曜なので1を引く)
        
        //年日付時間曜日(ファイルの名前用)の出力
        let defaultFormat = DateFormatter()
        defaultFormat.dateFormat = "y_M_d_k_H:m:s"
        let defaultDayTime = defaultFormat.string(from: now)
        
        //時間の出力
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "Hmm"
        let stringTime = timeFormat.string(from: now)
        let intTime = Int(stringTime)
        
        let classTime = String(getClassTime(intTime: intTime!))//時限の出力
        
        
      
        
        let directoryName = week + classTime    //保存するディレクトリの名前
        let fileName = defaultDayTime + ".png" //保存するファイルの名前
        
        let DocumentPath = NSHomeDirectory() + "/Documents"
        
        let path = "file://" + DocumentPath + "/" + directoryName + "/" + fileName
        let url:URL = NSURL(string: path)! as URL
        print(path)
        
        
        let pngImageData = image.pngData()
        
        do{
            try pngImageData?.write(to: url)
        
        }catch{
            print("errorfile")
        }
        
    }
    
}
