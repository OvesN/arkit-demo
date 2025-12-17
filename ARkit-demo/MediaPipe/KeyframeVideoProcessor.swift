//import AVFoundation
//import MediaPipeTasksVision
//import Combine
//
///// Processes video files with keyframe matching
//class KeyframeVideoProcessor: ObservableObject {
//    
//    
//    @Published var currentFrame: UIImage?
//    @Published var isProcessing: Bool = false
//    @Published var progress: Double = 0
//    @Published var matchResult: KeyframeMatchResult?
//    
//    
//    private var poseLandmarker: PoseLandmarker?
//    private(set) var keyframeMatcher: KeyframeMatcher
//    private var shouldStop = false
//    
//    
//    private let frameSubject = PassthroughSubject<(UIImage, KeyframeMatchResult? ), Never>()
//    var framePublisher: AnyPublisher<(UIImage, KeyframeMatchResult?), Never> {
//        frameSubject.eraseToAnyPublisher()
//    }
//    
//    
//    init(isRightArm: Bool = true) {
//        self.keyframeMatcher = KeyframeMatcher(isRightArm: isRightArm)
//        setupPoseLandmarker()
//    }
//    
//    private func setupPoseLandmarker() {
//        guard let modelPath = Bundle.main.path(forResource: "pose_landmarker_full", ofType: "task") else {
//            print("Model file not found")
//            return
//        }
//        
//        do {
//            let options = PoseLandmarkerOptions()
//            options.baseOptions. modelAssetPath = modelPath
//            options.runningMode = . video
//            options.numPoses = 1
//            options.minPoseDetectionConfidence = 0.5
//            options.minPosePresenceConfidence = 0.5
//            options.minTrackingConfidence = 0.5
//            
//            poseLandmarker = try PoseLandmarker(options: options)
//            print("PoseLandmarker initialized")
//        } catch {
//            print("Failed to create PoseLandmarker: \(error)")
//        }
//    }
//    
//    // MARK: - Video Processing
//    
//    func processVideo(url: URL) {
//        guard ! isProcessing else { return }
//        
//        isProcessing = true
//        shouldStop = false
//        keyframeMatcher.reset()
//        
//        DispatchQueue. global(qos: .userInitiated).async { [weak self] in
//            self?.processVideoFrames(url: url)
//        }
//    }
//    
//    func stop() {
//        shouldStop = true
//    }
//    
//    private func processVideoFrames(url: URL) {
//        let asset = AVAsset(url:  url)
//        
//        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
//            finishProcessing()
//            return
//        }
//        
//        let assetReader:  AVAssetReader
//        do {
//            assetReader = try AVAssetReader(asset: asset)
//        } catch {
//            print("Failed to create asset reader: \(error)")
//            finishProcessing()
//            return
//        }
//        
//        let outputSettings:  [String: Any] = [
//            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
//        ]
//        
//        let trackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
//        assetReader.add(trackOutput)
//        assetReader.startReading()
//        
//        let duration = asset.duration.seconds
//        let frameRate = videoTrack.nominalFrameRate
//        var frameCount = 0
//        let processInterval = max(1, Int(frameRate / 15)) // Process ~15 fps
//        
//        while assetReader.status == .reading && !shouldStop {
//            guard let sampleBuffer = trackOutput.copyNextSampleBuffer(),
//                  let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//                continue
//            }
//            
//            frameCount += 1
//            
//            // Skip frames for performance
//            if frameCount % processInterval != 0 { continue }
//            
//            let currentTime = Double(frameCount) / Double(frameRate)
//            let timestampMs = Int(currentTime * 1000)
//            
//            // Update progress
//            DispatchQueue. main.async { [weak self] in
//                self?.progress = currentTime / duration
//            }
//            
//            // Convert to image
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let context = CIContext()
//            guard let cgImage = context.createCGImage(ciImage, from: ciImage. extent) else {
//                continue
//            }
//            let uiImage = UIImage(cgImage: cgImage)
//            let imageSize = uiImage.size
//            
//            // Detect pose
//            guard let mpImage = try? MPImage(pixelBuffer: pixelBuffer),
//                  let result = try? poseLandmarker?. detect(videoFrame: mpImage, timestampInMilliseconds: timestampMs),
//                  let landmarks = result.landmarks.first else {
//                publishFrame(image: uiImage, result: nil)
//                continue
//            }
//            
//            // Create pose data and match keyframes
//            let poseData = MediaPipePoseData(
//                landmarks: landmarks,
//                imageSize: imageSize,
//                timestamp: currentTime
//            )
//            
//            let matchResult = keyframeMatcher.update(with: poseData)
//            
//            publishFrame(image: uiImage, result: matchResult)
//            
//            // Control playback speed
//            Thread.sleep(forTimeInterval: 1.0 / 30.0)
//        }
//        
//        finishProcessing()
//    }
//    
//    private func publishFrame(image: UIImage, result: KeyframeMatchResult?) {
//        DispatchQueue. main.async { [weak self] in
//            self?.currentFrame = image
//            self?.matchResult = result
//            self?.frameSubject.send((image, result))
//        }
//    }
//    
//    private func finishProcessing() {
//        DispatchQueue. main.async { [weak self] in
//            self?.isProcessing = false
//            self?.progress = 1.0
//        }
//    }
//    
//    func reset() {
//        stop()
//        keyframeMatcher.reset()
//        currentFrame = nil
//        matchResult = nil
//        progress = 0
//    }
//}
