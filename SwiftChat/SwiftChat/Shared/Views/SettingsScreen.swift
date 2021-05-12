//
//  SettingsScreen.swift
//  SwiftChat
//
//  Created by Anton Makeev on 11.05.2021.
//

import SwiftUI

struct SettingsScreen: View {
    
    @StateObject private var model = ChatScreenModel()
    @EnvironmentObject var userInfo: UserInfo
    
    private var isValidUser: Bool {
        userInfo.userName.trimmingCharacters(in: .whitespaces).isNotEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("Username")) {
                TextField("E.g. Josh Applesheed", text: $userInfo.userName)
                
                NavigationLink("Continue", destination: ClientsList(model: model))
                    .disabled(!isValidUser)
            }
        }
        .onDisappear(perform: onAppear)
        .navigationTitle("Settings")
    }
    
    
    private func onAppear() {
        model.connect(username: userInfo.userName, userID: userInfo.userID)
    }
    
    private func onDisappear(){
        model.disconnect()
    }
}
