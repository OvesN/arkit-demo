import RealityKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context _: Context) -> ARView {
        return BodyARView(frame: .zero)
    }

    func updateUIView(_: ARView, context _: Context) {}
}

#Preview {
    ContentView()
}
