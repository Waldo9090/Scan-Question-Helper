import Foundation
import AVFoundation

// Models for streaming responses
struct ChatGPTStreamResponse: Codable {
    let choices: [StreamChoice]
}

struct StreamChoice: Codable {
    let delta: Delta
}

struct Delta: Codable {
    let content: String?
}

/// A custom URLSessionDataDelegate that processes streaming responses from the OpenAI API.
class StreamingDelegate: NSObject, URLSessionDataDelegate {
    var onReceiveChunk: (String) -> Void
    var onCompletion: () -> Void
    var dataBuffer: String = ""
    
    init(onReceiveChunk: @escaping (String) -> Void, onCompletion: @escaping () -> Void) {
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