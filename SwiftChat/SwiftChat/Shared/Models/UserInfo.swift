//
//  UserInfo.swift
//  SwiftChat
//
//  Created by Anton Makeev on 11.05.2021.
//

import Foundation

class UserInfo: ObservableObject {
    @Published var userName = ""
    let userID = UUID()
}

struct UserInfoStr: Decodable {
    let userName: String
    let userID: UUID
}
