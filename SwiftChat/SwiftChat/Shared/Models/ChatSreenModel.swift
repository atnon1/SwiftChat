//
//  ChatSreenModel.swift
//  SwiftChat
//
//  Created by Anton Makeev on 09.05.2021.
//

import Combine
import Foundation

final class ChatScreenModel: ObservableObject {
    
    private var username: String?
    private var userID: UUID?
    @Published private(set) var clients = [UserInfoStr]()
    
    @Published private(set) var messages: [ReceivingChatMessage] = []
    private var webSocketTask: URLSessionWebSocketTask?
    
    func send(text: String, to toUserID: UUID) {
        guard let username = username, let userID = userID else { return }
        let message = SubmittedChatMessage(message: text, user: username, fromUserID: userID, toUserID: toUserID)
        guard let json = try? JSONEncoder().encode(message),
              let jsonString = String(data: json, encoding: .utf8)
        else { return }
        
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func connect(username: String, userID: UUID) {
        self.username = username
        self.userID = userID
        let url = URL(string: "ws://192.168.1.69:8080/chat")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.receive(completionHandler: onReceive)
        webSocketTask?.resume()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        webSocketTask?.receive(completionHandler: onReceive)
        
        if case .success(let message) = incoming {
            onMessage(message: message)
        } else if case .failure(let error) = incoming {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func onMessage(message: URLSessionWebSocketTask.Message) {
        if case .string(let text) = message {
            if let id = userID, text == "sendID" {
                webSocketTask?.send(.string(id.uuidString)) { error in
                    if let error = error {
                        print("Error sending user ID: \(error.localizedDescription)")
                    }
                }
            }
//            guard let data = text.data(using: .utf8),
//                  let chatMessage = try? JSONDecoder().decode(ReceivingChatMessage.self, from: data)
//            else  { return }
            
            if let data = text.data(using: .utf8) {
                if let chatMessage = try? JSONDecoder().decode(ReceivingChatMessage.self, from: data) {
                    DispatchQueue.main.async { [weak self] in
                        self?.messages.append(chatMessage)
                    }
               }
                if let client = try? JSONDecoder().decode(UserInfoStr.self, from: data) {
                    DispatchQueue.main.async { [weak self] in
                        if self?.clients.contains(where: { $0.userID == client.userID }) != true {
                            self?.clients.append(client)
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        disconnect()
    }
}
