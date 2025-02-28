//
//  ContentView.swift
//  BruinEatsApp
//
//  Created by Shiyu Ye on 1/31/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = BruinEatsModel()
    var body: some View {
        NavigationStack {
            RestaurantListView()
                .environmentObject(model)
        }
    }
}

#Preview {
    ContentView()
}
