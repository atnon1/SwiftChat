//
//  Models.swift
//  SwiftChat
//
//  Created by Anton Makeev on 10.05.2021.
//

import Foundation

struct SubmittedChatMessage: Encodable {
    let message: String
    let user: String
    let fromUserID: UUID
    let toUserID: UUID
}

struct ReceivingChatMessage: Decodable, Identifiable {
    let date: Date
    let id: UUID
    let message: String
    let user: String
    let fromUserID: UUID
    let toUserID: UUID
}
