//
//  ClientsList.swift
//  SwiftChat
//
//  Created by Anton Makeev on 12.05.2021.
//

import SwiftUI

struct ClientsList: View {
    
    @StateObject var model: ChatScreenModel
    @EnvironmentObject var userInfo: UserInfo
    
    var body: some View {
        List {
            ForEach(model.clients, id: \.userID) { client in
                NavigationLink(client.userName, destination: ChatScreen(model: model, destinationUserID: client.userID)
                )
            }
        }
        //.onAppear(perform: onAppear)
        //.onDisappear(perform: onDisappear)
    }
    

    
}
