//
//  main.swift
//  
//
//  Created by Anton Makeev on 09.05.2021.
//

import Vapor

var env = try Environment.detect()
let app = Application(env)
app.http.server.configuration.hostname = "0.0.0.0"
var clientConnections = Set<WebSocket>()
var clientConnectionsID: [UUID: WebSocket] = [:]


defer {
    app.shutdown()
}

app.webSocket("chat") { req, client in
    clientConnections.insert(client)
    client.send("sendID")
    
    client.onText { _, text in
        do {
            if let id = UUID(text) {
                clientConnectionsID[id] = client
                try sendAvaliableClients(to: client)
                try sendClientToEveryone(clientID: id)
                return
            }
            guard let data = text.data(using: .utf8) else { return }
            let incomingMessage = try JSONDecoder().decode(SubmittedChatMessage.self, from: data)
            let outgoingMessage = ReceivingChatMessage(message: incomingMessage.message, user: incomingMessage.user, fromUserID: incomingMessage.fromUserID, toUserID: incomingMessage.toUserID)
            let json = try JSONEncoder().encode(outgoingMessage)
            
            guard let jsonString = String(data: json, encoding: .utf8) else { return }
            
            client.send(jsonString)
            if let destinationClient = clientConnectionsID[incomingMessage.toUserID] {
                destinationClient.send(jsonString)
            }
        } catch {
            print(error)
        }
    }
    
    client.onClose.whenComplete { _ in
        clientConnections.remove(client)
        if let elementToRemove = clientConnectionsID.first(where: { $0.value == client }) {
            clientConnectionsID[elementToRemove.key] = nil
        }
    }
}

private func sendAvaliableClients(to client: WebSocket) throws {
    for (id, destinationClient) in clientConnectionsID {
        if destinationClient != client {
            let userInfo = UserInfoStr(userName: id.uuidString, userID: id)
            let json = try JSONEncoder().encode(userInfo)
            guard let jsonString = String(data: json, encoding: .utf8) else { return }
            client.send(jsonString)
        }
    }
}

private func sendClientToEveryone(clientID: UUID) throws {
    for (destinationID, destinationClient) in clientConnectionsID {
        if destinationID != clientID {
            let userInfo = UserInfoStr(userName: clientID.uuidString, userID: clientID)
            let json = try JSONEncoder().encode(userInfo)
            guard let jsonString = String(data: json, encoding: .utf8) else { return }
            destinationClient.send(jsonString)
        }
    }
}

try app.run()


