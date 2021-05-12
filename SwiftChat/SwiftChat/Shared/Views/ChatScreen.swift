//
//  ChatScreen.swift
//  SwiftChat
//
//  Created by Anton Makeev on 09.05.2021.
//

import SwiftUI

struct ChatScreen: View {
    @ObservedObject var model: ChatScreenModel
    @EnvironmentObject private var userInfo: UserInfo
    @State private var message = ""
    var destinationUserID: UUID
    var chatMessages: [ReceivingChatMessage] {
        model.messages.filter { $0.fromUserID == destinationUserID || $0.toUserID == destinationUserID }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 8) {
                        ForEach(chatMessages) { message in
                            ChatMessageRow(message: message, isUser: message.fromUserID == userInfo.userID)
                                .padding()
                                .id(message.id)
                        }
                    }
                    .onChange(of: model.messages.count, perform: { _ in
                        scrollToLastMessage(proxy: proxy)
                    })
                }
            }
            
            HStack {
                TextField("Message", text: $message, onEditingChanged: { _ in }, onCommit: onCommit)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(5)
                
                Button(action: onCommit) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.system(size: 20))
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
                .disabled(message.isEmpty)
                
            }
            .padding()
            
        }
        //.onAppear(perform: onAppear)
        //.onDisappear(perform: onDisappear)
    }
    
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let message = model.messages.last {
            withAnimation(.easeOut(duration: 0.4)) {
                proxy.scrollTo(message.id, anchor: .bottom)
            }
        }
    }
    
    private func onAppear() {
        model.connect(username: userInfo.userName, userID: userInfo.userID)
    }
    
    private func onDisappear(){
        model.disconnect()
    }
    
    private func onCommit() {
        if message.isNotEmpty {
            model.send(text: message, to: destinationUserID)
            message = ""
        }
    }
    
}
