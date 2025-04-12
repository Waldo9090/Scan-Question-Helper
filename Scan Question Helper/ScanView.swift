import SwiftUI
import UIKit

// MARK: - Custom Camera Picker
struct CustomCameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed.
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CustomCameraPicker
        
        init(parent: CustomCameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Custom Photo Library Picker
struct CustomPhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType  // Typically .photoLibrary

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed.
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CustomPhotoLibraryPicker
        
        init(parent: CustomPhotoLibraryPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Main ScanView Using Custom Pickers
struct ScanView: View {
    @State private var selectedImage: UIImage?
    @State private var showCameraPicker = false
    @State private var showPhotoLibraryPicker = false
    @State private var navigateToMathChat = false

    @Environment(\.presentationMode) var presentationMode

    private var placeholderImage: UIImage {
        UIImage(named: "MathPlaceholder") ?? UIImage()
    }
    
    private func generateHapticFeedback() {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.impactOccurred()
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("Scan Problem")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 110)
                        .multilineTextAlignment(.center)
                    
                    Text("Use the camera to capture your problems")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    
                    Image(uiImage: selectedImage ?? placeholderImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 350, height: 350)
                        .clipped()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    
                    // Button for taking a picture using the camera.
                    Button(action: {
                        showCameraPicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Take Picture")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Button for uploading a picture from the photo library.
                    Button(action: {
                        showPhotoLibraryPicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                            Text("Upload Picture")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Extra spacer or padding to ensure content sits above the TabBar.
                    Spacer(minLength: 0)
                        .frame(height: 80)
                }
                // Alternatively, you can use a bottom padding:
                // .padding(.bottom, 80)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .background(
                NavigationLink(
                    destination: MathChatView(selectedImage: selectedImage ?? placeholderImage),
                    isActive: $navigateToMathChat,
                    label: { EmptyView() }
                )
            )
        }
        .preferredColorScheme(.dark)
        // Present the Custom Camera Picker
        .sheet(isPresented: $showCameraPicker) {
            CustomCameraPicker(image: $selectedImage, sourceType: .camera)
        }
        // Present the Custom Photo Library Picker
        .sheet(isPresented: $showPhotoLibraryPicker) {
            CustomPhotoLibraryPicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                generateHapticFeedback()
                navigateToMathChat = true
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
            .preferredColorScheme(.dark)
    }
}
