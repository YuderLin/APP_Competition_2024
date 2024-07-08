//
//  ViewController.swift
//  APP_Competition_2024
//
//  Created by STUDIO A on 2024/7/7.
//
import UIKit
import AVFoundation
import Vision
import SwiftUI

protocol HandSwiperDelegate {
    func thumbsDown()
    func thumbsUp()
}

class ViewController: UIViewController, HandSwiperDelegate {
    
    
    // MARK: - Music
    var player: AVAudioPlayer?

        func MusicDidLoad() {
            // 配置音頻
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playback, mode: .default, options: [])
                try audioSession.setActive(true)
            } catch {
                print("Failed to set up audio session: \(error)")
            }
            
            // 初始化播放器
            if let urlone = Bundle.main.url(forResource: "MusicOne", withExtension: "mp3") {
                do {
                    player = try AVAudioPlayer(contentsOf: urlone)
                    player?.numberOfLoops = -1
                } catch {
                    print("Failed to initialize AVAudioPlayer: \(error)")
                }
            } else {
                print("Audio file not found")
            }
            
            // 播放音樂
            player?.play()
        }
    
    // MARK: - Thumb
    func thumbsDown() {
        if let firstView = stackContainer.subviews.last as? CardView {
            firstView.leftSwipeClicked(stackContainerView: stackContainer)
        }
    }
    
    func thumbsUp() {
        if let firstView = stackContainer.subviews.last as? CardView {
            firstView.rightSwipeClicked(stackContainerView: stackContainer)
        }
    }
    
    // MARK: - Properties
    var modelData = [
        DataModel(bgColor: UIColor(displayP3Red: 255/255, green: 193/255, blue: 193/255, alpha: 1)),
        DataModel(bgColor: UIColor(displayP3Red: 216/255, green: 191/255, blue: 216/255, alpha: 1)),
        DataModel(bgColor: UIColor(displayP3Red: 255/255, green: 193/255, blue: 193/255, alpha: 1)),
        DataModel(bgColor: UIColor(displayP3Red: 216/255, green: 191/255, blue: 216/255, alpha: 1)),
        DataModel(bgColor: UIColor(displayP3Red: 255/255, green: 193/255, blue: 193/255, alpha: 1)),
        DataModel(bgColor: UIColor(displayP3Red: 216/255, green: 191/255, blue: 216/255, alpha: 1)),
        DataModel(bgColor: UIColor(displayP3Red: 255/255, green: 193/255, blue: 193/255, alpha: 1)),
        DataModel(bgColor: UIColor(displayP3Red: 216/255, green: 191/255, blue: 216/255, alpha: 1))
    ]
    
    var stackContainer: StackContainerView!
    var buttonStackView: UIStackView!
    var leftButton: UIButton!, rightButton: UIButton!
    var cameraView: CameraView!
    
    // MARK: - Init
    override func loadView() {
        view = UIView()
        stackContainer = StackContainerView()
        view.addSubview(stackContainer)
        configureStackContainer()
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        addCameraView()
        configureNavigationBarButtonItem() // 將導航按鈕配置移到這裡
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "握力訓練"
        stackContainer.dataSource = self
        addButtons()

        // 確認導航欄不隱藏
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // 播放音樂
        MusicDidLoad()

    }
    func configureNavigationBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetTapped))
    }

    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    let message = UILabel()
    var handDelegate: HandSwiperDelegate?
    
    func addCameraView() {
        cameraView = CameraView()
        self.handDelegate = self
        view.addSubview(cameraView)
        
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 450).isActive = true
    }
    
    // MARK: - Configurations
    func configureStackContainer() {
        stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -230).isActive = true
        stackContainer.widthAnchor.constraint(equalToConstant: 400).isActive = true
        stackContainer.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func addButtons() {
        leftButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "Nope"), for: .normal)
        leftButton.addTarget(self, action: #selector(onButtonPress(sender:)), for: .touchUpInside)
        leftButton.tag = 0
        
        rightButton = UIButton(type: .custom)
        rightButton.setImage(UIImage(named: "Like"), for: .normal)
        rightButton.addTarget(self, action: #selector(onButtonPress(sender:)), for: .touchUpInside)
        rightButton.tag = 1
        
        buttonStackView = UIStackView(arrangedSubviews: [leftButton, rightButton])
        buttonStackView.distribution = .fillEqually
        self.view.addSubview(buttonStackView)
        
        buttonStackView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        buttonStackView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        buttonStackView.topAnchor.constraint(equalTo: stackContainer.bottomAnchor, constant: 30).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func onButtonPress(sender: UIButton) {
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
            sender.transform = CGAffineTransform.identity
        },
                       completion: { Void in() })
        
        if let firstView = stackContainer.subviews.last as? CardView {
            if sender.tag == 0 {
                firstView.leftSwipeClicked(stackContainerView: stackContainer)
            } else {
                firstView.rightSwipeClicked(stackContainerView: stackContainer)
            }
        }
    }
    
//    func configureNavigationBarButtonItem() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetTapped))
//    }
//    
    // MARK: - Handlers
    @objc func resetTapped() {
        stackContainer.reloadData()
        
        // 重新播放音樂
        player?.stop()
        player?.currentTime = 0
        player?.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession() throws {
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    var restingHand = true
    
    // 手勢座標
    func processPoints(_ points: [CGPoint?]) {
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        var pointsConverted: [CGPoint] = []
        for point in points {
            pointsConverted.append(previewLayer.layerPointConverted(fromCaptureDevicePoint: point!))
        }
        
        let thumbTip = pointsConverted[0]
        let indexTip = pointsConverted[1]
        let middleTip = pointsConverted[2]
        let ringTip = pointsConverted[3]
        let littleTip = pointsConverted[4]
        let wrist = pointsConverted[5]
        
        let Distance0 = sqrt(pow(thumbTip.x - wrist.x, 2) + pow(thumbTip.y - wrist.y, 2))
        let Distance1 = abs(thumbTip.y - wrist.y)
        let Distance2 = abs(thumbTip.y - wrist.y)
        let Distance3 = abs(thumbTip.y - wrist.y)
        let Distance4 = abs(thumbTip.y - wrist.y)
        let Distance5 = abs(thumbTip.y - wrist.y)
        let yDistance = Distance1 + Distance2 + Distance3 + Distance4 + Distance5
        print(yDistance, self.restingHand)
        
        let threshold: CGFloat = 120
        if ((yDistance >= threshold && self.restingHand) || (yDistance < threshold && !self.restingHand)) {
            print("👍")
            self.restingHand = !self.restingHand
            self.handDelegate?.thumbsUp()
        }
        if (yDistance < 120) {
            if self.restingHand {
                print("👎")
                self.restingHand = false
                self.handDelegate?.thumbsDown()
            }
        } else if (yDistance > 300) {
            if self.restingHand {
                print("👍")
                self.restingHand = false
                self.handDelegate?.thumbsUp()
            }
        } else {
            print("✋")
            self.restingHand = true
        }
        
        cameraView.showPoints(pointsConverted)
    }
}

extension ViewController: SwipeCardsDataSource {
    func card(at index: Int) -> CardView {
        let card = CardView(index: index)
        card.dataSource = modelData[index]
        return card
    }
    
    func numberOfCardsToShow() -> Int {
        return modelData.count
    }
    
    func emptyView() -> UIView? {
        return nil
    }
}

extension UIImage {
    static func getImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIColor {
    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random() % 256) / 255.0
            let green = CGFloat(arc4random() % 256) / 255.0
            let blue = CGFloat(arc4random() % 256) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        var middleTip: CGPoint?
        var ringTip: CGPoint?
        var littleTip: CGPoint?
        var wrist: CGPoint?
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                cameraView.showPoints([])
                return
            }
            
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let wristPoints = try observation.recognizedPoints(.all)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            let middleFingerPoints = try observation.recognizedPoints(.middleFinger)
            let ringFingerPoints = try observation.recognizedPoints(.ringFinger)
            let littleFingerPoints = try observation.recognizedPoints(.littleFinger)
            
            guard let thumbTipPoint = thumbPoints[.thumbTip],
                  let indexTipPoint = indexFingerPoints[.indexTip],
                  let middleTipPoint = middleFingerPoints[.middleTip],
                  let ringTipPoint = ringFingerPoints[.ringTip],
                  let littleTipPoint = littleFingerPoints[.littleTip],
                  let wristPoint = wristPoints[.wrist]
            else {
                cameraView.showPoints([])
                return
            }
            
            let confidenceThreshold: Float = 0.3
            guard thumbTipPoint.confidence > confidenceThreshold &&
                    indexTipPoint.confidence > confidenceThreshold &&
                    middleTipPoint.confidence > confidenceThreshold &&
                    ringTipPoint.confidence > confidenceThreshold &&
                    littleTipPoint.confidence > confidenceThreshold &&
                    wristPoint.confidence > confidenceThreshold
            else {
                cameraView.showPoints([])
                return
            }
            
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
            middleTip = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
            ringTip = CGPoint(x: ringTipPoint.location.x, y: 1 - ringTipPoint.location.y)
            littleTip = CGPoint(x: littleTipPoint.location.x, y: 1 - littleTipPoint.location.y)
            wrist = CGPoint(x: wristPoint.location.x, y: 1 - wristPoint.location.y)
            
            DispatchQueue.main.async {
                self.processPoints([thumbTip,
                                    indexTip,
                                    middleTip,
                                    ringTip,
                                    littleTip,
                                    wrist])
            }
        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}
