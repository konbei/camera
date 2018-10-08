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
    
    private var daycounts = 5
    private var classcounts = 6
    private var startClassTime:[Int] = []   //時限ごとの開始時刻データ
    private var finishClassTime:[Int] = []
    
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
    
    //写真データを格納するディレクトリを作成
    func makeDirectory(){
        let fileManager = FileManager.default
        let DocumentPath = NSHomeDirectory() + "/Documents"
        for day in 0..<daycounts{
            for classes in 0...classcounts{
                let DirectoryPath = DocumentPath + "/" + numberday(num: day) + "\(classes)"
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
        for i in 0..<classcounts{
            if(startClassTime[i] != 2359 && finishClassTime[i] != 2359 && startClassTime[i] <= finishClassTime[i]){
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeDirectory()
        startClassTime = [2359,2359,2359,2359,2359,2359]
        finishClassTime = [2359,2359,2359,2359,2359,2359]
        
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
        
      
        previewLayer.frame = view.bounds
        
        previewLayer.masksToBounds = true
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
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
    
    //ピンチで拡大縮小機能
     var zoomFactor: CGFloat = 1.0
    @IBAction func pinchZoom(_ sender: UIPinchGestureRecognizer) {
        let device = AVCaptureDevice.default(
            AVCaptureDevice.DeviceType.builtInWideAngleCamera,
            for: AVMediaType.video, // ビデオ入力
            position: AVCaptureDevice.Position.back) // バックカメラ
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat { return min(max(factor, 1.0), device!.activeFormat.videoMaxZoomFactor) }
        
        func update(scale factor: CGFloat) {
            do {
                try device!.lockForConfiguration()
                defer { device!.unlockForConfiguration() }
                device!.videoZoomFactor = factor
            } catch {
                debugPrint(error)
            }
        }
        
        let newScaleFactor = minMaxZoom(sender.scale * zoomFactor)
        
        switch sender.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            zoomFactor = minMaxZoom(newScaleFactor)
            update(scale: zoomFactor)
        default: break
        }
    }
}

