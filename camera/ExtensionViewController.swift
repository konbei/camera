//
//  ExtensionViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/10/02.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import Photos
//回転機能実装
extension UIImage {
    func rotated(degrees: CGFloat,width:CGFloat,height:CGFloat) -> UIImage? {
        
        let degreesToRadians: (CGFloat) -> CGFloat = { (degrees: CGFloat) in
            return degrees / 180.0 * CGFloat.pi
        }
        
        // Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: degreesToRadians(degrees))
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, 0.0)
        
        guard let bitmap: CGContext = UIGraphicsGetCurrentContext(), let unwrappedCgImage: CGImage = cgImage else {
            return nil
        }
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width/2.0, y: rotatedSize.height/2.0)
        
        // Rotate the image context
        bitmap.rotate(by: degreesToRadians(degrees))
        
        bitmap.scaleBy(x: CGFloat(1.0), y: -1.0)
        
        let rect: CGRect = CGRect(
            x: -width/2,
            y: -height/2,
            width: width,
            height: height)
        
        bitmap.draw(unwrappedCgImage, in: rect)
        
        guard let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// デリゲート部分を拡張する
extension CameraViewController:AVCapturePhotoCaptureDelegate {
    
    // 映像をキャプチャする
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Dataを取り出す
        guard let photoData = photo.fileDataRepresentation() else {
            return
        }
        // Dataから写真イメージを作る
        if var stillImage = UIImage(data: photoData){
            //AVCapturePhotoOutputで持ってきたUIImageの向きはlandscapcLeftで固定されてしまうので向きによってUIImage回転
            
            switch UIDevice.current.orientation{
            case .portraitUpsideDown:
                stillImage = stillImage.rotated(degrees: 270, width: stillImage.size.height, height: stillImage.size.width)!
            case .landscapeRight:
                stillImage = stillImage.rotated(degrees: 180, width: stillImage.size.width, height: stillImage.size.height)!
            case .portrait, .faceUp, .faceUp:
                stillImage = stillImage.rotated(degrees: 90, width: stillImage.size.height, height: stillImage.size.width)!
            default: break
            }

            
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
        defaultFormat.dateFormat = "y_MM_dd_HH:mm:ss"
        let defaultDayTime = defaultFormat.string(from: now)
        
        //時間の出力
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "Hmm"
        let stringTime = timeFormat.string(from: now)
        let intTime = Int(stringTime)
        
        let classTime = String(getClassTime(intTime: intTime!))//時限の出力
        
        
      
        var directoryName:String!
        if week != "Satur" && week != "Sun"{
             directoryName = week + classTime
        }else{
             directoryName = week
        }
            //保存するディレクトリの名前
        let fileName = defaultDayTime + ".png" //保存するファイルの名前
        
        let DocumentPath = NSHomeDirectory() + "/Documents"
        
        let path = "file://" + DocumentPath + "/" + directoryName + "/" + fileName
        let url:URL = NSURL(string: path)! as URL
        print(path)
        
        
        
        let saveImage =
            image.reSizeImage(reSize: CGSize(width: 80, height: 80))
        //サムネイルセット
        thumbnailImage.image = saveImage
        
        let pngImageData = image.pngData()
        
        do{
            try pngImageData?.write(to: url)
        
        }catch{
            print("errorfile")
        }
        
    }
    
}
