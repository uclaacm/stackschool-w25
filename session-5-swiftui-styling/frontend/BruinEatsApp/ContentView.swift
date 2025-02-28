//
//  ContentView.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 1/10/25.
//

import SwiftUI

struct ContentView: View {
   @StateObject private var model = BruinEatsModel()
   @StateObject private var appState = AppState()
   
   var body: some View {
       NavigationStack(path: $appState.routes) {
           // Show login/registration if no auth token, otherwise show restaurant list
           Group {
               if UserDefaults.standard.string(forKey: "authToken") == nil {
                   LoginScreen()
               } else {
                   RestaurantListView()
               }
           }
           .navigationDestination(for: Route.self) { route in
               switch route {
               case .register:
                   RegistrationScreen()
               case .login:
                   LoginScreen()
               case .restaurantlistview:
                   RestaurantListView()
               }
           }
       }
       .environmentObject(model)
       .environmentObject(appState)
   }
}
#Preview {
    ContentView()
}
