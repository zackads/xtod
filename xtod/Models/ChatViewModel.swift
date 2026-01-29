import SwiftUI
import ExyteChat
import OpenAI
internal import Combine

@MainActor
class ChatViewModel: ObservableObject {
    
    private let openAI: OpenAI
    @Published var messages: [Message] = []
    
    init() {
        self.openAI = OpenAI(apiToken: Environment.apiKey)

        let welcomeMessage = createMessage(userId: "bot", text: "Hey! What's up?")
        messages.append(welcomeMessage)
    }
    
    func send(draft: DraftMessage) {
        let userMessage = createMessage(userId: "user", text: draft.text, createdAt: draft.createdAt)
        messages.append(userMessage)
        
        // Create initial bot message for streaming
        let botMessageId = UUID().uuidString
        let botMessage = createMessage(messageId: botMessageId, userId: "bot", text: "typing...", status: .sending)
        messages.append(botMessage)
        
        // Start OpenAI response
        Task {
            await getOpenAIResponse(userText: draft.text, botMessageId: botMessageId)
        }
    }
    
    private func getOpenAIResponse(userText: String, botMessageId: String) async {
        do {
            // Create conversation context with all messages
            var chatMessages: [ChatQuery.ChatCompletionMessageParam] = [
                .system(.init(content: .textContent("You're a cheerful chatbot who brings joy and humor to every conversation. You answer with very very short and concise answer")))
            ]
            
            // Add recent conversation history (last 10 messages to keep context manageable)
            let recentMessages = messages.suffix(10)
            for message in recentMessages {
                if message.user.isCurrentUser {
                    chatMessages.append(.user(.init(content: .string(message.text))))
                } else if message.id != botMessageId { // Don't include the message we're currently generating
                    chatMessages.append(.assistant(.init(content: .textContent(message.text))))
                }
            }
            
            let query = ChatQuery(
                messages: chatMessages,
                model: .gpt5_nano,
                stream: false
            )
            
            // Get the complete response from OpenAI
            let result = try await openAI.chats(query: query)
            
            if let content = result.choices.first?.message.content {
                // Update the bot message with the complete response
                if let messageIndex = messages.firstIndex(where: { $0.id == botMessageId }) {
                    var updatedMessage = messages[messageIndex]
                    updatedMessage.text = content
                    updatedMessage.status = .sent
                    messages[messageIndex] = updatedMessage
                }
            }
            
        } catch {
            print("Error getting OpenAI response: \(error)")
            
            // Fallback to error message
            if let messageIndex = messages.firstIndex(where: { $0.id == botMessageId }) {
                var updatedMessage = messages[messageIndex]
                updatedMessage.text = "I'm having trouble connecting right now. Please try again in a moment. \n\n Error: \(error)"
                updatedMessage.status = .sent
                messages[messageIndex] = updatedMessage
            }
        }
    }
}

extension ChatViewModel {
    private func createMessage(
        messageId: String = UUID().uuidString,
        userId: String,
        text: String,
        status: Message.Status = .sent,
        createdAt: Date = Date()
    ) -> Message {
        let user = userId == "bot"
            ? User(id: "bot", name: "chatbot", avatarURL: self.createImageDataURL(named: "bot"), isCurrentUser: false)
            : User(id: "user", name: "You", avatarURL: nil, isCurrentUser: true)
        
        return Message(
            id: messageId,
            user: user,
            status: status,
            createdAt: createdAt,
            text: text
        )
    }
    
    // Helper function to create a data URL from an image in Assets for the chatbot avatar
    private func createImageDataURL(named imageName: String) -> URL? {
        guard let uiImage = UIImage(named: imageName),
              let imageData = uiImage.pngData() else {
            return nil
        }
        let base64String = imageData.base64EncodedString()
        let dataURLString = "data:image/png;base64,\(base64String)"
        return URL(string: dataURLString)
    }
}
