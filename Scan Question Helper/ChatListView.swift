import SwiftUI

struct ChatListView: View {
    @State private var showNewChat = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with points
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                    Text("0")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
            }
            .padding()
            
            // Welcome Message
            VStack(alignment: .leading, spacing: 12) {
                Text("Hi there! 👋")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text("Tap a task you need help with or ask anything in a new chat.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            
            // Task Options
            ScrollView {
                VStack(spacing: 15) {
                    TaskButton(title: "Essays", icon: "pencil", color: .yellow)
                    TaskButton(title: "Rewrites", icon: "pencil.and.outline", color: .pink)
                    TaskButton(title: "Summaries", icon: "book", color: .orange)
                }
                .padding()
            }
            
            Spacer()
            
            // Ask Anything Button
            Button(action: {
                showNewChat = true
            }) {
                HStack {
                    Text("Ask anything...")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(25)
                .padding()
            }
        }
        .background(Color.black)
        .navigationTitle("Chat with Solvo")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewChat) {
            NavigationStack {
                ChatDetailView()
            }
        }
    }
}

struct TaskButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.body)
                
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(15)
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatListView()
        }
    }
} 