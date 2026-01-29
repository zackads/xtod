import SwiftUI
import ExyteChat

struct ChatGoalView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some View {
        ChatView(messages: chatViewModel.messages) { draft in
            chatViewModel.send(draft: draft)
        }
        .setAvailableInputs([AvailableInputType.text])
        .navigationTitle("You funny chatbot")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChatGoalView()
    }
}
