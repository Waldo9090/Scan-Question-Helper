import SwiftUI

struct ImageCropView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var cropRect: CGRect
    @State private var showCroppedPreview = false
    @State private var croppedImage: UIImage?
    @State private var imageSize: CGSize = .zero
    @State private var imageFrame: CGRect = .zero
    @State private var isDragging = false
    
    init(image: UIImage) {
        self.image = image
        // Start with a centered rectangle crop frame
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let width = screenWidth * 0.8
        let height = screenHeight * 0.4
        let x = (screenWidth - width) / 2
        let y = (screenHeight - height) / 2
        _cropRect = State(initialValue: CGRect(x: x, y: y, width: width, height: height))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if showCroppedPreview, let croppedImage = croppedImage {
                    // Preview of cropped image
                    VStack {
                        Image(uiImage: croppedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                        
                        HStack(spacing: 40) {
                            Button(action: {
                                showCroppedPreview = false
                            }) {
                                Text("Recrop")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first,
                                   let rootViewController = window.rootViewController {
                                    let mathChatView = MathChatView(selectedImage: croppedImage)
                                    let hostingController = UIHostingController(rootView: NavigationStack { mathChatView })
                                    rootViewController.present(hostingController, animated: true)
                                    dismiss()
                                }
                            }) {
                                Text("Use Photo")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    // Image with crop overlay
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(GeometryReader { imageGeometry in
                            Color.clear.onAppear {
                                imageSize = imageGeometry.size
                                imageFrame = imageGeometry.frame(in: .global)
                            }
                        })
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Crop Frame with corners
                    ZStack {
                        // Semi-transparent overlay
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .mask(
                                Rectangle()
                                    .overlay(
                                        Rectangle()
                                            .frame(width: cropRect.width, height: cropRect.height)
                                            .position(x: cropRect.midX, y: cropRect.midY)
                                            .blendMode(.destinationOut)
                                    )
                            )
                        
                        // Crop rectangle outline
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: cropRect.width, height: cropRect.height)
                            .position(x: cropRect.midX, y: cropRect.midY)
                        
                        // Corner controls
                        Group {
                            // Top Left
                            CornerControl()
                                .position(x: cropRect.minX, y: cropRect.minY)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let newX = min(cropRect.maxX - 100, value.location.x)
                                        let newY = min(cropRect.maxY - 100, value.location.y)
                                        let deltaW = cropRect.minX - newX
                                        let deltaH = cropRect.minY - newY
                                        cropRect = CGRect(
                                            x: newX,
                                            y: newY,
                                            width: cropRect.width + deltaW,
                                            height: cropRect.height + deltaH
                                        )
                                    }
                                )
                            
                            // Top Right
                            CornerControl()
                                .position(x: cropRect.maxX, y: cropRect.minY)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let newWidth = max(100, value.location.x - cropRect.minX)
                                        let newY = min(cropRect.maxY - 100, value.location.y)
                                        let deltaH = cropRect.minY - newY
                                        cropRect = CGRect(
                                            x: cropRect.minX,
                                            y: newY,
                                            width: newWidth,
                                            height: cropRect.height + deltaH
                                        )
                                    }
                                )
                            
                            // Bottom Left
                            CornerControl()
                                .position(x: cropRect.minX, y: cropRect.maxY)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let newX = min(cropRect.maxX - 100, value.location.x)
                                        let newHeight = max(100, value.location.y - cropRect.minY)
                                        let deltaW = cropRect.minX - newX
                                        cropRect = CGRect(
                                            x: newX,
                                            y: cropRect.minY,
                                            width: cropRect.width + deltaW,
                                            height: newHeight
                                        )
                                    }
                                )
                            
                            // Bottom Right
                            CornerControl()
                                .position(x: cropRect.maxX, y: cropRect.maxY)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let newWidth = max(100, value.location.x - cropRect.minX)
                                        let newHeight = max(100, value.location.y - cropRect.minY)
                                        cropRect = CGRect(
                                            x: cropRect.minX,
                                            y: cropRect.minY,
                                            width: newWidth,
                                            height: newHeight
                                        )
                                    }
                                )
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                } else {
                                    cropRect.origin.x += value.translation.width
                                    cropRect.origin.y += value.translation.height
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                    
                    // Bottom controls
                    VStack {
                        Spacer()
                        HStack(spacing: 40) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                if let cropped = cropImage() {
                                    croppedImage = cropped
                                    showCroppedPreview = true
                                }
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
    
    private func cropImage() -> UIImage? {
        // Calculate the scale between the display size and actual image size
        let scale = image.size.width / imageFrame.width
        
        // Convert crop rect to image coordinates
        let normalizedX = (cropRect.minX - imageFrame.minX) * scale
        let normalizedY = (cropRect.minY - imageFrame.minY) * scale
        let normalizedWidth = cropRect.width * scale
        let normalizedHeight = cropRect.height * scale
        
        let cropZone = CGRect(x: normalizedX,
                            y: normalizedY,
                            width: normalizedWidth,
                            height: normalizedHeight)
        
        // Ensure we're within the image bounds
        let validCropZone = cropZone.intersection(CGRect(origin: .zero, size: image.size))
        
        guard let cgImage = image.cgImage?.cropping(to: validCropZone) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

struct CornerControl: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 30, height: 30)
            .shadow(color: .black.opacity(0.3), radius: 3)
    }
} 