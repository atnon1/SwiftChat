//
//  File.swift
//  
//
//  Created by Anton Makeev on 09.05.2021.
//

import Vapor

extension WebSocket: Hashable {
    public static func == (lhs: WebSocket, rhs: WebSocket) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
