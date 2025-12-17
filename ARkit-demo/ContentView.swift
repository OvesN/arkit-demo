import SwiftUI
import RealityKit
import Combine

struct ContentView: View {
    @State private var selectedMode: InputMode = .camera
    @State private var isRightArm: Bool = true
    
    enum InputMode: String, CaseIterable {
        case camera = "Camera (ARKit)"
        case video = "Video (MediaPipe)"
    }
    
    var body: some View {
        ZStack {
            // Background AR View
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            // UI Overlay - at the top
            VStack(spacing: 0) {
                // Mode Picker
                Picker("Input Mode", selection:  $selectedMode) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(. segmented)
                .padding(. horizontal)
                .padding(.top, 8)
                
                // Arm Selection
                Picker("Arm", selection: $isRightArm) {
                    Text("Right Arm").tag(true)
                    Text("Left Arm").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()  // Push everything to the top
            }
        }
    }
}

// MARK:  - ARKit View

struct ARKitExerciseView: View {
    let isRightArm: Bool
    @StateObject private var viewModel = ARKitExerciseViewModel()
    
    var body: some View {
        ZStack {
            // AR View - This should be visible
            ARKitViewContainer(viewModel:  viewModel, isRightArm: isRightArm)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay - Made transparent to allow AR view to show through
            KeyframeOverlayView(
                matcher:  viewModel.matcher,
                matchResult: viewModel.lastResult
            )
            .allowsHitTesting(false)  // Allow touches to pass through to AR view
            
            // Reset button - small and at top right
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { viewModel.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            . font(.system(size: 16))
                            .foregroundColor(. white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                    . padding(.top, 60)
                }
                
                Spacer()
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
    @ObservedObject var viewModel:  ARKitExerciseViewModel
    let isRightArm:  Bool
    
    func makeUIView(context: Context) -> KeyframeBodyARView {
        let arView = KeyframeBodyARView(frame: . zero, isRightArm:  isRightArm)
        viewModel.bind(to: arView)
        return arView
    }
    
    func updateUIView(_ uiView: KeyframeBodyARView, context:  Context) {}
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> BodyARView {
        return BodyARView(frame: .zero)
    }
    
    func updateUIView(_ uiView: BodyARView, context: Context) {}
}

// MARK: - Video Picker

struct VideoPickerView:  UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.mediaTypes = ["public. movie"]
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
            if let url = info[.mediaURL] as?  URL {
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
