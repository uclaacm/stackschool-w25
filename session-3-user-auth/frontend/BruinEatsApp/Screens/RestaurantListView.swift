//
//  RestaurantListView.swift
//  BruinEatsApp
//
//  Created by Samuel Perrott on 24/01/25.
//

import SwiftUI

struct RestaurantListView: View {
    @EnvironmentObject private var model: BruinEatsModel
    @EnvironmentObject private var appState: AppState
    @State private var showingAddSheet = false
    @State private var errorMessage = ""
    
    var body: some View {
        List(model.restaurants) { restaurant in
            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                RestaurantRowView(restaurant: restaurant)
            }
        }
        .navigationTitle("BruinEats")
//        .toolbar {
//            Button("Add Restaurant") {
//                showingAddSheet = true
//            }
//        }
        .sheet(isPresented: $showingAddSheet) {
            AddRestaurantView()
        }
        .task {
            do {
                try await model.fetchRestaurants()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Sign Out") {
                    model.signOut()
                    appState.signOut()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Restaurant") {
                    showingAddSheet = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
                    .foregroundColor(.gray)
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.averageRating))
                }
            }
        }
    }
}

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var model: BruinEatsModel
    @State private var showingReviewSheet = false
    
    var body: some View {         List {
            Section("Details") {
                AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                
                Text(restaurant.description)
                HStack {
                    Image(systemName: "star.fill")
                    Text(String(format: "%.1f", restaurant.averageRating))
                }
            }
            
            Section("Reviews") { // reviews
                ForEach(model.reviewsByRestaurant[restaurant.id] ?? []) { review in
                    ReviewRowView(review: review)
                }
            }
        }
        .navigationTitle(restaurant.name)
        .toolbar {
            Button("Add Review") {
                showingReviewSheet = true
            }
        }
        .sheet(isPresented: $showingReviewSheet) {
            AddReviewView(restaurantId: restaurant.id)
        }
        .task {
            do {
                try await model.fetchReviews(for: restaurant.id)
            } catch {}
        }
    }
}

struct AddRestaurantView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: BruinEatsModel
    @State private var name = ""
    @State private var description = ""
    @State private var imageUrl = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                TextField("Image URL (optional)", text: $imageUrl)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Restaurant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            do {
                                try await model.addRestaurant(
                                    name: name,
                                    description: description,
                                    imageUrl: imageUrl.isEmpty ? nil : imageUrl
                                )
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

struct AddReviewView: View {
    let restaurantId: UUID
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: BruinEatsModel
    @State private var rating = 3
    @State private var comment = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Rating", selection: $rating) {
                    ForEach(1...5, id: \.self) { rating in
                        HStack {
                            Text("\(rating)")
                            Image(systemName: "star.fill")
                        }.tag(rating)
                    }
                }
                
                TextField("Comment", text: $comment, axis: .vertical)
                    .lineLimit(3...6)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            do {
                                try await model.addReview(
                                    restaurantId: restaurantId,
                                    rating: rating,
                                    comment: comment
                                )
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .disabled(comment.isEmpty)
                }
            }
        }
    }
}

struct ReviewRowView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(review.user.username)
                .font(.headline)

            HStack {
                ForEach(0..<review.rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            Text(review.comment)
                .font(.body)
            Text(review.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
