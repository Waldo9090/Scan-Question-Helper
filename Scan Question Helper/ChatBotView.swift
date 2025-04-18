//
//  ChatBotView.swift
//  AI Homework Helper
//
//  Created by Ayush Mahna on 2/2/25.
//

import SwiftUI

// MARK: - Message Model

/// A simple model representing a message in the chat.
/// It now supports either text or an image (stored as Data).
struct Message: Identifiable, Codable, Equatable {
    let id: UUID = UUID()
    var text: String?
    let isUser: Bool
    // Store image data for messages that include an image.
    var imageData: Data? = nil
    
    /// A computed property to get a UIImage from imageData.
    var image: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }
}

// MARK: - OpenAI API Response Models

// For non-streaming responses (if needed)
struct ChatGPTResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: APIMessage
}

struct APIMessage: Codable {
    let role: String
    let content: String
}



// MARK: - ChatBotView

struct ChatBotView: View {
    let systemPrompt: String
    let initialMessage: String
    /// If there is an existing chat history, load it; otherwise start fresh.
    let existingChatHistory: [Message]?
    
    // A unique key for storing this chat's history.
    private let chatStorageKey: String = UUID().uuidString
    
    @State private var messages: [Message] = []
    @State private var userInput: String = ""
    @State private var isLoading: Bool = false  // Used for disabling input while streaming.
    
    // For image picker presentation.
    @State private var isShowingImagePicker: Bool = false
    // Holds the image selected from the image picker.
    @State private var selectedImage: UIImage? = nil
    // Tracks the image picker source type: camera or photo library.
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    // The ID of the bot message that is currently streaming its response.
    @State private var currentBotMessageID: UUID? = nil
    
    // Optionally, show an alert if the camera is not available.
    @State private var showCameraAlert: Bool = false

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageRowView(message: message, currentBotMessageID: currentBotMessageID) {
                                messageContentView(message: message)
                            }
                            .id(message.id)
                        }
                        
                        if isLoading && currentBotMessageID == nil {
                            ProgressView()
                                .padding()
                        }
                    }
                    .onChange(of: messages) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Divider()
                .padding(.horizontal)
            
            // Input area with a menu button for attaching or taking photos.
            HStack {
                Menu {
                    Button("Attach Photo") {
                        imagePickerSource = .photoLibrary
                        isShowingImagePicker = true
                    }
                    Button("Take Photo") {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            imagePickerSource = .camera
                            // Delay sheet presentation to ensure imagePickerSource is updated.
                            DispatchQueue.main.async {
                                isShowingImagePicker = true
                            }
                        } else {
                            showCameraAlert = true
                        }
                    }
                } label: {
                    Image(systemName: "paperclip")
                        .font(.title2)
                }
                .padding(.trailing, 4)
                
                TextField("Type your message...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("Chat Tutor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadChatHistory()
            if messages.isEmpty {
                let initial = Message(text: initialMessage, isUser: false)
                messages.append(initial)
            }
        }
        .onDisappear {
            saveChatHistory()
        }
        .sheet(isPresented: $isShowingImagePicker, onDismiss: imagePickerDismissed) {
            ImagePicker(image: $selectedImage, sourceType: imagePickerSource)
        }
        .alert(isPresented: $showCameraAlert) {
            Alert(title: Text("Camera Unavailable"),
                  message: Text("The camera is not available on this device."),
                  dismissButton: .default(Text("OK")))
        }
        .background(Color(UIColor.systemBackground))
    }
    
    /// Returns a view displaying either text or an image for a message.
    @ViewBuilder
    private func messageContentView(message: Message) -> some View {
        if let image = message.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .frame(maxWidth: 200, maxHeight: 200)
        } else if let text = message.text {
            Text(text)
                .padding()
                .background(message.isUser ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(10)
        }
    }
    
    /// Called when the image picker is dismissed.
    private func imagePickerDismissed() {
        if let image = selectedImage {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let imageMessage = Message(text: nil, isUser: true, imageData: imageData)
                messages.append(imageMessage)
                
                let placeholderText = "Use this image for context."
                let messageWithPlaceholder = Message(text: placeholderText, isUser: true)
                messages.append(messageWithPlaceholder)
                
                fetchBotResponse()
            }
            selectedImage = nil
        }
    }
    
    /// Sends the user message (if any) and calls the OpenAI API for a response.
    private func sendMessage() {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        let userMessage = Message(text: trimmedInput, isUser: true)
        messages.append(userMessage)
        userInput = ""
        
        fetchBotResponse()
    }
    
    /// Calls the OpenAI API using the chat history and system prompt with streaming enabled.
    private func fetchBotResponse() {
        isLoading = true
        
        var apiMessages: [[String: String]] = [
            [
                "role": "system",
                "content": systemPrompt
            ]
        ]
        
        for message in messages {
            let role = message.isUser ? "user" : "assistant"
            let content: String
            if let text = message.text {
                content = text
            } else if message.imageData != nil {
                content = "[User sent an image]"
            } else {
                content = ""
            }
            apiMessages.append([
                "role": role,
                "content": content
            ])
        }
        
        let streamingMessage = Message(text: "", isUser: false)
        messages.append(streamingMessage)
        currentBotMessageID = streamingMessage.id
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": apiMessages,
            "temperature": 0.7,
            "stream": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error encoding body: \(error)")
            isLoading = false
            return
        }
        
        let delegate = StreamingDelegate(
            onReceiveChunk: { chunk in
                if let index = messages.firstIndex(where: { $0.id == currentBotMessageID }) {
                    messages[index].text = (messages[index].text ?? "") + chunk
                }
            },
            onCompletion: {
                isLoading = false
                currentBotMessageID = nil
            }
        )
        
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    /// Saves the chat history to UserDefaults.
    private func saveChatHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(messages)
            UserDefaults.standard.set(data, forKey: chatStorageKey)
            print("Chat history saved with key: \(chatStorageKey)")
        } catch {
            print("Failed to save chat history: \(error)")
        }
    }
    
    /// Loads the chat history from UserDefaults, if available.
    private func loadChatHistory() {
        if let data = UserDefaults.standard.data(forKey: chatStorageKey) {
            do {
                let decoder = JSONDecoder()
                let savedMessages = try decoder.decode([Message].self, from: data)
                messages = savedMessages
            } catch {
                print("Failed to load chat history: \(error)")
            }
        } else if let existingHistory = existingChatHistory {
            messages = existingHistory
        }
    }
}

// MARK: - MessageRowView

/// A subview that renders a single message row.
/// This helps break up the code and assists the compiler with type-checking.
struct MessageRowView<Content: View>: View {
    let message: Message
    let currentBotMessageID: UUID?
    let content: () -> Content

    var body: some View {
        Group {
            if message.isUser {
                HStack {
                    Spacer()
                    content()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                }
                .padding(.horizontal)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    content()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                    
                    if message.id == currentBotMessageID {
                        TypingIndicatorView()
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - StreamingDelegate


// MARK: - TypingIndicatorView

/// A simple view showing a pulsing circle to indicate that the bot is typing.
struct TypingIndicatorView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.5

    var body: some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 10, height: 10)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

// MARK: - ImagePicker

/// A wrapper for UIImagePickerController to select images.
/// Now accepts a sourceType parameter to allow for the camera or photo library.
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    typealias UIViewControllerType = UIImagePickerController

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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
}

// MARK: - ChatBotView_Previews

struct ChatBotView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatBotView(
                systemPrompt: "You are a Mathematics tutor. Please explain your solutions step by step.",
                initialMessage: "Hello! I'm here to help with Mathematics. What do you need assistance with today?",
                existingChatHistory: nil
            )
        }
    }
}
