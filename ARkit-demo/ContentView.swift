import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedMode: InputMode = .camera
    @State private var isRightArm: Bool = true
    
    enum InputMode: String, CaseIterable {
        case camera = "Camera (ARKit)"
        case video = "Video (MediaPipe)"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode Picker
                Picker("Input Mode", selection: $selectedMode) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(. segmented)
                .padding()
                
                // Arm Selection
                Picker("Arm", selection: $isRightArm) {
                    Text("Right Arm").tag(true)
                    Text("Left Arm").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(. horizontal)
                
                // Content based on mode
                ARKitExerciseView(isRightArm: isRightArm)
//                switch selectedMode {
//                case .camera:
//                    ARKitExerciseView(isRightArm: isRightArm)
//                case . video:
//                    MediaPipeExerciseView(isRightArm: isRightArm)
//                }
            }
            .navigationTitle("Bicep Curl Trainer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - ARKit View

struct ARKitExerciseView: View {
    let isRightArm: Bool
    @StateObject private var viewModel = ARKitExerciseViewModel()
    
    var body: some View {
        ZStack {
            // AR View
            ARKitViewContainer(viewModel: viewModel, isRightArm: isRightArm)
                . edgesIgnoringSafeArea(.bottom)
            
            // Overlay
            KeyframeOverlayView(
                matcher: viewModel.matcher,
                matchResult: viewModel.lastResult
            )
            
            // Reset button
            VStack {
                Spacer()
                
                Button(action: { viewModel.reset() }) {
                    Label("Reset", systemImage: "arrow. counterclockwise")
                        .padding()
                        . background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                .padding(. bottom, 30)
            }
        }
    }
}

class ARKitExerciseViewModel: ObservableObject {
    @Published var lastResult: KeyframeMatchResult?
    @Published var matcher = KeyframeMatcher(isRightArm: true)
    
    private var cancellables = Set<AnyCancellable>()
    private weak var arView: KeyframeBodyARView?
    
    func bind(to arView: KeyframeBodyARView) {
        self.arView = arView
        self.matcher = arView.keyframeMatcher
        
        arView.matchResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.lastResult = result
            }
            .store(in: &cancellables)
    }
    
    func reset() {
        arView?.resetExercise()
        lastResult = nil
    }
}

struct ARKitViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARKitExerciseViewModel
    let isRightArm: Bool
    
    func makeUIView(context: Context) -> KeyframeBodyARView {
        let arView = KeyframeBodyARView(frame: . zero, isRightArm: isRightArm)
        viewModel.bind(to: arView)
        return arView
    }
    
    func updateUIView(_ uiView: KeyframeBodyARView, context: Context) {}
}

// MARK: - MediaPipe View

//struct MediaPipeExerciseView: View {
//    let isRightArm: Bool
//    @StateObject private var processor: KeyframeVideoProcessor
//    @State private var showVideoPicker = false
//    @State private var selectedVideoURL: URL?
//    
//    init(isRightArm: Bool) {
//        self.isRightArm = isRightArm
//        self._processor = StateObject(wrappedValue: KeyframeVideoProcessor(isRightArm: isRightArm))
//    }
//    
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//            
//            // Video frame
//            if let image = processor.currentFrame {
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//            }
//            
//            // Keyframe overlay
//            KeyframeOverlayView(
//                matcher: processor.keyframeMatcher,
//                matchResult: processor.matchResult
//            )
//            
//            // Controls
//            VStack {
//                // Progress bar
//                if processor.isProcessing {
//                    ProgressView(value: processor.progress)
//                        .padding()
//                }
//                
//                Spacer()
//                
//                // Buttons
//                HStack(spacing: 20) {
//                    Button(action: { showVideoPicker = true }) {
//                        Label("Select Video", systemImage: "video.badge.plus")
//                            . padding()
//                            . background(.ultraThinMaterial)
//                            .cornerRadius(12)
//                    }
//                    
//                    if processor.isProcessing {
//                        Button(action: { processor.stop() }) {
//                            Label("Stop", systemImage: "stop.fill")
//                                . padding()
//                                .background(Color.red.opacity(0.8))
//                                . foregroundColor(.white)
//                                .cornerRadius(12)
//                        }
//                    }
//                    
//                    Button(action: { processor.reset() }) {
//                        Label("Reset", systemImage: "arrow.counterclockwise")
//                            .padding()
//                            .background(. ultraThinMaterial)
//                            . cornerRadius(12)
//                    }
//                }
//                . padding(.bottom, 30)
//            }
//        }
//        .sheet(isPresented: $showVideoPicker) {
//            VideoPickerView(videoURL: $selectedVideoURL)
//        }
//        .onChange(of: selectedVideoURL) { newURL in
//            if let url = newURL {
//                processor.processVideo(url: url)
//            }
//        }
//    }
//}

// MARK: - Video Picker

struct VideoPickerView: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoPickerView
        
        init(_ parent: VideoPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                // Copy to temp location
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".mov")
                try? FileManager.default.copyItem(at: url, to: tempURL)
                parent.videoURL = tempURL
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
