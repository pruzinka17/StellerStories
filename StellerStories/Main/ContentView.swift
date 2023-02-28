//
//  ContentView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 16.02.2023.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        let networkService = NetworkService()
        let userService = UserService(
            
            networkService: networkService
        )
        
        ProfileView(userService: userService)
    }
}
