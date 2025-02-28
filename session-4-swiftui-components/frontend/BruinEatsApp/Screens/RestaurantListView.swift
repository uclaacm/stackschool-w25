//
//  RestaurantListView.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 2/24/25.
//

import SwiftUI

struct RestaurantListView: View {
    @EnvironmentObject private var model: BruinEatsModel
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("BruinEats")
                .font(.largeTitle)
                .padding()

            List(model.restaurants) { restaurant in
                RestaurantRowView(restaurant: restaurant)
            }
            .listStyle(PlainListStyle())
            .task {
                do {
                    try await model.fetchRestaurants()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                Color.gray.opacity(0.3)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.headline)
                Text(restaurant.description)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format:"%.1f", restaurant.averageRating))
                }
            }
        }
    }
}
