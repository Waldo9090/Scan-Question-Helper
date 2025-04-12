import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraModel()
    @State private var showImagePicker = false
    @State private var frameRect = CGRect(x: 50, y: 150, width: 300, height: 400)
    @State private var selectedCorner: Corner?
    @State private var lastLocation: CGPoint?
    
    enum Corner: Int {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            
            // Overlay for dimming outside frame
            Path { path in
                path.addRect(UIScreen.main.bounds)
                path.addRect(frameRect)
            }
            .fill(Color.black.opacity(0.5))
            .allowsHitTesting(false)
            
            // Resizable frame
            GeometryReader { geometry in
                ZStack {
                    // Frame border
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: frameRect.width, height: frameRect.height)
                        .position(x: frameRect.midX, y: frameRect.midY)
                    
                    // Corner circles
                    ForEach(0..<4) { index in
                        let corner = Corner(rawValue: index)!
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .position(cornerPosition(for: corner))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        updateFrame(corner: corner, location: value.location)
                                    }
                            )
                    }
                }
            }
            
            // Bottom controls
            VStack {
                Spacer()
                HStack {
                    // Gallery button
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Capture button
                    Button(action: {
                        camera.capturePhoto(in: frameRect)
                    }) {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    
                    Spacer()
                    
                    // Close button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            SharedImagePicker(image: $camera.capturedImage, sourceType: .photoLibrary)
        }
        .onChange(of: camera.capturedImage) { newImage in
            if newImage != nil {
                dismiss()
            }
        }
    }
    
    private func cornerPosition(for corner: Corner) -> CGPoint {
        switch corner {
        case .topLeft:
            return CGPoint(x: frameRect.minX, y: frameRect.minY)
        case .topRight:
            return CGPoint(x: frameRect.maxX, y: frameRect.minY)
        case .bottomLeft:
            return CGPoint(x: frameRect.minX, y: frameRect.maxY)
        case .bottomRight:
            return CGPoint(x: frameRect.maxX, y: frameRect.maxY)
        }
    }
    
    private func updateFrame(corner: Corner, location: CGPoint) {
        var newFrame = frameRect
        
        switch corner {
        case .topLeft:
            newFrame.origin.x = min(location.x, frameRect.maxX - 100)
            newFrame.origin.y = min(location.y, frameRect.maxY - 100)
            newFrame.size.width = frameRect.maxX - newFrame.origin.x
            newFrame.size.height = frameRect.maxY - newFrame.origin.y
        case .topRight:
            newFrame.size.width = max(location.x - frameRect.minX, 100)
            newFrame.origin.y = min(location.y, frameRect.maxY - 100)
            newFrame.size.height = frameRect.maxY - newFrame.origin.y
        case .bottomLeft:
            newFrame.origin.x = min(location.x, frameRect.maxX - 100)
            newFrame.size.width = frameRect.maxX - newFrame.origin.x
            newFrame.size.height = max(location.y - frameRect.minY, 100)
        case .bottomRight:
            newFrame.size.width = max(location.x - frameRect.minX, 100)
            newFrame.size.height = max(location.y - frameRect.minY, 100)
        }
        
        frameRect = newFrame
    }
}

class CameraModel: NSObject, ObservableObject {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var capturedImage: UIImage?
    
    override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.global(qos: .background).async {
                self.setUp()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    DispatchQueue.global(qos: .background).async {
                        self.setUp()
                    }
                }
            }
        default:
            alert = true
        }
    }
    
    func setUp() {
        do {
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("No camera available")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.session.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    func capturePhoto(in frame: CGRect) {
        let settings = AVCapturePhotoSettings()
        self.output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            self.capturedImage = image
            self.session.stopRunning()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.frame
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
} 