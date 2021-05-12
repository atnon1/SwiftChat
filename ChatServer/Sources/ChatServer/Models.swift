//
//  Models.swift
//  
//
//  Created by Anton Makeev on 09.05.2021.
//

import Foundation

struct SubmittedChatMessage: Decodable {
    let message: String
    let user: String
    let fromUserID: UUID
    let toUserID: UUID
}

struct ReceivingChatMessage: Encodable, Identifiable {
    let date = Date()
    let id = UUID()
    let message: String
    let user: String
    let fromUserID: UUID
    let toUserID: UUID
}
