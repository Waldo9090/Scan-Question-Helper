import SwiftUI

struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Chat with Solvo")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.black)
            
            // Messages
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ChatBubble(message: "What can I help you with today?", isUser: false)
                        .padding(.top)
                }
                .padding()
            }
            
            // Message Input
            HStack(spacing: 12) {
                TextField("Type here...", text: $messageText)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(25)
                
                Button(action: {}) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                        .padding(12)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}

struct ChatBubble: View {
    let message: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(message)
                .padding()
                .background(isUser ? Color.purple : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(20)
            
            if !isUser { Spacer() }
        }
    }
}

struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailView()
    }
} 