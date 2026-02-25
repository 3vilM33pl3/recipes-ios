import SwiftUI
import UIKit

struct RecipeGridItem: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail
            AsyncImage(url: recipe.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: Configuration.cornerRadius))

            // Title
            Text(recipe.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundStyle(.primary)

            // Metadata
            HStack(spacing: 12) {
                if let prepTime = recipe.prepTime {
                    Label(prepTime, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let difficulty = recipe.difficulty {
                    Label(difficulty, systemImage: "chart.bar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .contextMenu {
            Button {
                shareRecipe()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            Button {
                // Bookmark functionality (future)
            } label: {
                Label("Bookmark", systemImage: "bookmark")
            }
        }
    }

    private func shareRecipe() {
        Task {
            await HapticService.shared.impact(.medium)
        }

        let activityVC = UIActivityViewController(
            activityItems: recipe.shareItems(),
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    RecipeGridItem(recipe: Recipe(
        id: "1",
        slug: "sample-recipe",
        title: "Delicious Chocolate Cake",
        prepTime: "15 minutes",
        difficulty: "Easy"
    ))
    .frame(width: 180)
}
