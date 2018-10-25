//
//  ViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/09/23.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//
import UIKit
import CoreData
import AVFoundation






class CameraViewController: UIViewController {
    var a = UITableViewCell()
    
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
    

    private var startClassTime:[Int] = []   //時限ごとの開始時刻データ
    private var finishClassTime:[Int] = []
    private let util = Util()
   
    
    //写真データを格納するディレクトリを作成
    func makeDirectory(){
        let fileManager = FileManager.default
        let DocumentPath = NSHomeDirectory() + "/Documents"
        for day in 0..<self.util.dayCounts{
            if day > 4{
                let DirectoryPath = DocumentPath + "/" + self.util.numberday(num: day)
                if fileManager.fileExists(atPath: DirectoryPath) == false{
                    do{
                        try fileManager.createDirectory(atPath: DirectoryPath, withIntermediateDirectories: true, attributes: nil)
                    }catch{
                        print("error")
                    }
                }
            }else{
                for classes in 0...self.util.classCounts{
                    let DirectoryPath = DocumentPath + "/" + self.util.numberday(num: day) + "\(classes)"
                    if fileManager.fileExists(atPath: DirectoryPath) == false{
                        do{
                            try fileManager.createDirectory(atPath: DirectoryPath, withIntermediateDirectories: true, attributes: nil)
                        }catch{
                            print("error")
                        }
                    }
                }
            }
            
        }
    }
    
    //Core Dataから開始時刻と終了時刻を取ってくる
    func getClassTimeData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SettingsTime> = SettingsTime.fetchRequest()
        let SettingsData = try! context.fetch(fetchRequest)
        if !SettingsData.isEmpty{
            for i in 0..<SettingsData.count{
                startClassTime[i] = Int(SettingsData[i].startClassTime)
                finishClassTime[i] = Int(SettingsData[i].finishClassTime)
                
            }
        }
    }
    //現時時刻から何限か返す
    func getClassTime(intTime:Int)->Int{
        for i in 0..<self.util.classCounts{
            if startClassTime[i] != 9999 && finishClassTime[i] != 9999{
                let  ClassTimeRange = startClassTime[i]...finishClassTime[i]
                if ClassTimeRange.contains(intTime) == true{
                    let classTime = i+1
                    return classTime
                }
            }
        }
        return 0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
        getClassTimeData()
    }
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //プレビューサムネイルを設定
        let thumbnailData:Data? = defaults.data(forKey: "thumbnailImage")
        if thumbnailData != nil{
            let thumbnail = UIImage(data: thumbnailData!)//?.reSizeImage(reSize: CGSize(width: thumbnailImage.frame.width, height: thumbnailImage.frame.height))
            thumbnailImage.image = thumbnail
        }else{
            thumbnailImage.image = UIImage(named: "noImage")
        }
        
        
        
        makeDirectory()
        startClassTime = [9999,9999,9999,9999,9999,9999]
        finishClassTime = [9999,9999,9999,9999,9999,9999]
        
        //カメラ起動〜実行
        
        // セッション実行中ならば中断する
        if session.isRunning {
            return
        }
        // 入出力の設定
        setupInputOutput()
        // プレビューレイヤの設定
        setPreviewLayer()
        // セッション開始
        session.startRunning()
        
        //ピンチ拡大、縮小追加
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(CameraViewController.pinchedGesture(gestureRecgnizer:)))
        self.previewView.addGestureRecognizer(pinchGesture)
        
        // デバイスが回転したときに通知するイベントハンドラを設定する
        notification.addObserver(self,
                                 selector: #selector(self.changedDeviceOrientation(_:)),
                                 name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    //カメラ機能の実装
    
    @IBOutlet weak var previewView: UIView!
    
    //シャッターボタン押した時の動作
    @IBAction func takePhoto(_ sender: Any) {
        let captureSetting = AVCapturePhotoSettings()
        captureSetting.flashMode = .auto
        captureSetting.isAutoStillImageStabilizationEnabled = true
        captureSetting.isHighResolutionPhotoEnabled = false
        // キャプチャのイメージ処理はデリゲートに任せる
        photoOutputObj.capturePhoto(with: captureSetting, delegate: self)
        
    }
    
    // インスタンスの作成
    var session = AVCaptureSession()
    var photoOutputObj = AVCapturePhotoOutput()
    // 通知センターを作る
    let notification = NotificationCenter.default
    
    // 入出力の設定
    func setupInputOutput(){
        photoOutputObj.connection(with: AVMediaType.video)?.videoOrientation = .landscapeLeft
        //解像度の指定:以前は4k以上の解像度で保存されていた（20-30MB)ので重かった。hd(3-5MB)で出力、FHDだと(15-20MB)かかり重くなるので考え中
        session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        // 入力の設定
        do {
            //デバイスの取得
            let device = AVCaptureDevice.default(
                AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                for: AVMediaType.video, // ビデオ入力
                position: AVCaptureDevice.Position.back) // バックカメラ
            
            // 入力元
            let input = try AVCaptureDeviceInput(device: device!)
            if session.canAddInput(input){
                session.addInput(input)
            } else {
                print("セッションに入力を追加できなかった")
                return
            }
        } catch  let error as NSError {
            print("カメラがない \(error)")
            return
        }
        
        // 出力の設定
        if session.canAddOutput(photoOutputObj) {
            session.addOutput(photoOutputObj)
        } else {
            print("セッションに出力を追加できなかった")
            return
        }
    }
    
    // プレビューレイヤの設定
    func setPreviewLayer(){
        // プレビューレイヤを作る
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        previewLayer.masksToBounds = true
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // previewViewに追加する
        previewView.layer.addSublayer(previewLayer)
    }
    // デバイスの向きが変わったときに呼び出すメソッド
    @objc func changedDeviceOrientation(_ notification :Notification) {
        // photoOutputObj.connectionの回転向きをデバイスと合わせる
        if let photoOutputConnection = self.photoOutputObj.connection(with: AVMediaType.video) {
            switch UIDevice.current.orientation {
            case .portrait:
                photoOutputConnection.videoOrientation = .portrait
            case .portraitUpsideDown:
                photoOutputConnection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                photoOutputConnection.videoOrientation = .landscapeRight
            case .landscapeRight:
                photoOutputConnection.videoOrientation = .landscapeLeft
            default:
                break
            }
        }
    }
    
    var thumbnailPath:String!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    //ピンチズーム、縮小
    var oldZoomScale: CGFloat = 1.0
    var camera:AVCaptureDevice!
    @objc func pinchedGesture(gestureRecgnizer: UIPinchGestureRecognizer) {
        do {
            camera = AVCaptureDevice.default(
                AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                for: AVMediaType.video, // ビデオ入力
                position: AVCaptureDevice.Position.back)
            try camera.lockForConfiguration()
            // ズームの最大値
            let maxZoomScale: CGFloat = 6.0
            // ズームの最小値
            let minZoomScale: CGFloat = 1.0
            // 現在のカメラのズーム度
            var currentZoomScale: CGFloat = camera.videoZoomFactor
            // ピンチの度合い
            let pinchZoomScale: CGFloat = gestureRecgnizer.scale
            
            // ピンチアウトの時、前回のズームに今回のズーム-1を指定
            // 例: 前回3.0, 今回1.2のとき、currentZoomScale=3.2
            if pinchZoomScale > 1.0 {
                currentZoomScale = oldZoomScale+pinchZoomScale-1
            } else {
                currentZoomScale = oldZoomScale-(1-pinchZoomScale)*oldZoomScale
            }
            
            // 最小値より小さく、最大値より大きくならないようにする
            if currentZoomScale < minZoomScale {
                currentZoomScale = minZoomScale
            }
            else if currentZoomScale > maxZoomScale {
                currentZoomScale = maxZoomScale
            }
            
            // 画面から指が離れたとき、stateがEndedになる。
            if gestureRecgnizer.state == .ended {
                oldZoomScale = currentZoomScale
            }
            
            camera.videoZoomFactor = currentZoomScale
            camera.unlockForConfiguration()
        } catch {
            // handle error
            return
        }
    }
    
    func focusWithMode(focusMode : AVCaptureDevice.FocusMode, exposeWithMode expusureMode :AVCaptureDevice.ExposureMode, atDevicePoint point:CGPoint, motiorSubjectAreaChange monitorSubjectAreaChange:Bool) {
        DispatchQueue(label: "session queue").async {
            
            
            
            let device = AVCaptureDevice.default(
                AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                for: AVMediaType.video, // ビデオ入力
                position: AVCaptureDevice.Position.back) // バックカメラ
            
            
            print(device!.focusPointOfInterest)
            print(device!.focusMode)
            print(device!.exposurePointOfInterest)
            print(device!.exposureMode)
            do {
                try device?.lockForConfiguration()
                if(device!.isFocusPointOfInterestSupported && device!.isFocusModeSupported(focusMode)){
                    device!.focusPointOfInterest = point
                    device!.focusMode = focusMode
                }
                if(device!.isExposurePointOfInterestSupported && device!.isExposureModeSupported(expusureMode)){
                    device!.exposurePointOfInterest = point
                    device!.exposureMode = expusureMode
                }
                
                device?.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                
                device!.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device!.unlockForConfiguration()
                device?.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                device!.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            } catch let error as NSError {
                print(error.debugDescription)
            }
            
        }
        
    }
    
    
    //プレビューに移動
    @IBAction func comeCamera (segue: UIStoryboardSegue){
        //プレビューサムネイルを設定
        let thumbnailData:Data? = defaults.data(forKey: "thumbnailImage")
        if thumbnailData != nil{
            let thumbnail = UIImage(data: thumbnailData!)//?.reSizeImage(reSize: CGSize(width: thumbnailImage.frame.width, height: thumbnailImage.frame.height))
            thumbnailImage.image = thumbnail
        }else{
            thumbnailImage.image = UIImage(named: "noImage")
        }
    }
    //選択した写真と写真のパス送る
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "previewImage"){
            (segue.destination as! SelectedImageViewController).selectedImage = thumbnailImage.image
            (segue.destination as! SelectedImageViewController).selectedImagePath = thumbnailPath
            (segue.destination as! SelectedImageViewController).selectedDirectory = "All"
            
            (segue.destination as! SelectedImageViewController).selectRow = 0
            (segue.destination as! SelectedImageViewController).movedPreview = true
        }
    }
    
    
    @IBAction func goToPreview(_ sender: Any) {
        performSegue(withIdentifier: "previewImage", sender: nil)
    }
    
}

