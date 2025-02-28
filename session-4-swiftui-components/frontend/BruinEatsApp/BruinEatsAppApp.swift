//
//  BruinEatsAppApp.swift
//  BruinEatsApp
//
//  Created by Shiyu Ye on 1/31/25.
//

import SwiftUI

@main
struct BruinEatsAppApp: App {
    @StateObject private var model = BruinEatsModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
