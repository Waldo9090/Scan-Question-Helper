import SwiftUI
import AVFoundation
import Photos

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraController = CameraController()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showCropView = false
    
    var body: some View {
        ZStack {
            // Camera preview
            if let previewLayer = cameraController.previewLayer {
                CameraPreviewView(previewLayer: previewLayer)
                    .ignoresSafeArea()
            }
            
            // Camera controls overlay
            VStack {
                // Top bar with close button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                .background(LinearGradient(
                    colors: [Color.black.opacity(0.6), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                
                Spacer()
                
                // Bottom controls
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
                    .padding(.leading, 30)
                    
                    Spacer()
                    
                    // Capture button
                    Button(action: {
                        cameraController.capturePhoto { image in
                            if let image = image {
                                selectedImage = image
                                showCropView = true
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Spacer to balance layout
                    Spacer()
                        .frame(width: 90)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            SharedImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
                .onDisappear {
                    if selectedImage != nil {
                        showCropView = true
                    }
                }
        }
        .fullScreenCover(isPresented: $showCropView, content: {
            if let image = selectedImage {
                ImageCropView(image: image)
            }
        })
        .onAppear {
            cameraController.checkPermissions()
        }
    }
}

// Camera preview view
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.frame
    }
}

// Camera controller
class CameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var completionHandler: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func checkPermissions() {
        // Check camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        case .restricted, .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
        
        // Check photo library permission
        PHPhotoLibrary.requestAuthorization { status in
            // Handle photo library permission
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            self.photoOutput = output
        }
        
        session.commitConfiguration()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        DispatchQueue.main.async {
            self.previewLayer = previewLayer
            self.captureSession = session
            session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput = self.photoOutput else {
            completion(nil)
            return
        }
        
        self.completionHandler = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Error capturing photo: \(error)")
                self.completionHandler?(nil)
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                self.completionHandler?(nil)
                return
            }
            
            self.completionHandler?(image)
        }
    }
} 