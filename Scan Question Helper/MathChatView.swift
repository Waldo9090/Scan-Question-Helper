import SwiftUI
import UIKit

// MARK: - Message Model

/// A simple model representing a message in the chat.
/// It supports text messages and/or an image (stored as Data).

// MARK: - MathChatView

struct MathChatView: View {
    let selectedImage: UIImage

    @State private var messages: [Message] = []
    @State private var isLoading: Bool = false
    /// The ID of the bot message currently receiving streaming text.
    @State private var currentBotMessageID: UUID? = nil

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // Chat messages scroll view.
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    messageContentView(message: message)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                                } else {
                                    HStack {
                                        messageContentView(message: message)
                                        if message.id == currentBotMessageID {
                                            TypingIndicatorView()
                                        }
                                        Spacer()
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                                }
                            }
                            .padding(.horizontal)
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
        }
        .navigationTitle("Math Chat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // hide default back button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Rescan")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.purple))
                        .foregroundColor(.white)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            addUserImageMessage()
            fetchSolution()
        }
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
                .background(message.isUser ? Color.purple.opacity(0.7) : Color.gray.opacity(0.3))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(10)
        }
    }
    
    /// Adds the user's image as a chat bubble.
    private func addUserImageMessage() {
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            let userMessage = Message(text: nil, isUser: true, imageData: imageData)
            messages.append(userMessage)
            
            // Also add a placeholder text message so the assistant can refer to it.
            let placeholder = Message(text: "Help me solve this problem.", isUser: true)
            messages.append(placeholder)
        }
    }
    
    /// Calls the GPT‑4 API with the image encoded in the prompt.
    private func fetchSolution() {
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            let errorMsg = Message(text: "Could not encode image.", isUser: false)
            messages.append(errorMsg)
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        isLoading = true
        
        // Build the prompt: include a system message and a user message with the image data.
        let systemMessage: [String: String] = [
            "role": "system",
            "content": "You are a Mathematics tutor. Provide a detailed, step-by-step solution with explanations."
        ]
        let userContent = """
        This image contains a math problem. Please analyze and provide a detailed explanation.
        [IMAGE DATA: \(base64Image)]
        """
        let userMessage: [String: String] = [
            "role": "user",
            "content": userContent
        ]
        let apiMessages = [systemMessage, userMessage]
        
        // Add a placeholder assistant message for streaming response.
        let botPlaceholder = Message(text: "", isUser: false)
        messages.append(botPlaceholder)
        currentBotMessageID = botPlaceholder.id
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            updateBotMessage(with: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o",  // or "gpt-3.5-turbo" if preferred
            "messages": apiMessages,
            "temperature": 0.2,
            "stream": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            updateBotMessage(with: "Error encoding request: \(error.localizedDescription)")
            return
        }
        
        let delegate = StreamingDelegate { chunk in
            // Append each chunk to the bot message text.
            if let index = messages.firstIndex(where: { $0.id == currentBotMessageID }) {
                messages[index].text = (messages[index].text ?? "") + chunk
            }
        } onCompletion: {
            isLoading = false
            currentBotMessageID = nil
        }
        
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    /// Updates the current bot message in case of error.
    private func updateBotMessage(with text: String) {
        if let index = messages.firstIndex(where: { $0.id == currentBotMessageID }) {
            messages[index].text = text
        } else {
            messages.append(Message(text: text, isUser: false))
        }
        isLoading = false
        currentBotMessageID = nil
    }
}

// MARK: - StreamingDelegate

/// A custom URLSessionDataDelegate that processes streaming responses from the OpenAI API.
private class StreamingDelegate: NSObject, URLSessionDataDelegate {
    var onReceiveChunk: (String) -> Void
    var onCompletion: () -> Void
    var dataBuffer: String = ""
    
    init(onReceiveChunk: @escaping (String) -> Void,
         onCompletion: @escaping () -> Void) {
        self.onReceiveChunk = onReceiveChunk
        self.onCompletion = onCompletion
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let chunkString = String(data: data, encoding: .utf8) else { return }
        
        dataBuffer += chunkString
        let lines = dataBuffer.components(separatedBy: "\n")
        dataBuffer = lines.last ?? ""
        
        for line in lines.dropLast() {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))
                if jsonString == "[DONE]" {
                    DispatchQueue.main.async { self.onCompletion() }
                    return
                }
                if let jsonData = jsonString.data(using: .utf8) {
                    do {
                        let streamResponse = try JSONDecoder().decode(ChatGPTStreamResponse.self, from: jsonData)
                        if let content = streamResponse.choices.first?.delta.content {
                            DispatchQueue.main.async { self.onReceiveChunk(content) }
                        }
                    } catch {
                        print("Failed to decode stream response: \(error)")
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Stream completed with error: \(error)")
        }
        DispatchQueue.main.async { self.onCompletion() }
    }
}



// MARK: - Preview

struct MathChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            // Replace "MathPlaceholder" with an actual image asset name.
            MathChatView(selectedImage: UIImage(named: "MathPlaceholder") ?? UIImage())
        }
        .preferredColorScheme(.light)
    }
}
