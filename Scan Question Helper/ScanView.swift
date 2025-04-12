import SwiftUI

struct ScanView: View {
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var isShowingFullScreen = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                // Header Section
                VStack(spacing: 15) {
                    Text("Scan & Solve")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Take a photo or upload an image of your question")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Main Scan Area
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .strokeBorder(Color.purple.opacity(0.3), lineWidth: 2, antialiased: true)
                        )
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(25)
                            .onTapGesture {
                                isShowingFullScreen = true
                            }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "doc.viewfinder")
                                .font(.system(size: 50))
                                .foregroundColor(.purple)
                            
                            Text("No image selected")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(height: 400)
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 15) {
                    // Camera Button
                    Button(action: {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCamera = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Photo")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(15)
                    }
                    
                    // Upload Button
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                            Text("Upload Image")
                        }
                        .font(.headline)
                        .foregroundColor(.purple)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                
                // Tips Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tips for best results:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    TipRow(icon: "light.max", text: "Ensure good lighting")
                    TipRow(icon: "camera.filters", text: "Keep the image clear and focused")
                    TipRow(icon: "crop", text: "Crop out unnecessary parts")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            SharedImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            SharedImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .fullScreenCover(isPresented: $isShowingFullScreen) {
            if let image = selectedImage {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    
                    VStack {
                        HStack {
                            Button(action: {
                                isShowingFullScreen = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
