import SwiftUI

// MARK: - Recipe Header

struct RecipeHeaderView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.title)
                .font(.title)
                .fontWeight(.bold)

            if let description = recipe.recipeDescription {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            if let difficulty = recipe.difficulty {
                HStack {
                    Image(systemName: "chart.bar.fill")
                    Text(difficulty)
                }
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(difficultyColor(difficulty).opacity(0.2))
                .foregroundStyle(difficultyColor(difficulty))
                .clipShape(Capsule())
            }
        }
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy":
            return .green
        case "medium":
            return .orange
        case "hard":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Recipe Metadata

struct RecipeMetadataView: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 24) {
            if let prepTime = recipe.prepTime {
                MetadataItem(icon: "clock", title: "Prep", value: prepTime)
            }

            if let cookTime = recipe.cookTime {
                MetadataItem(icon: "flame", title: "Cook", value: cookTime)
            }

            if let servings = recipe.servings {
                MetadataItem(icon: "person.2", title: "Servings", value: servings)
            }
        }
    }
}

struct MetadataItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Ingredients Section

struct IngredientsSection: View {
    let ingredients: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(ingredients.enumerated()), id: \.offset) { _, ingredient in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(.blue)
                            .padding(.top, 6)

                        Text(ingredient)
                            .font(.body)
                    }
                }
            }
            .padding(.leading, 8)
        }
    }
}

// MARK: - Instructions Section

struct InstructionsSection: View {
    let instructions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.blue)
                                .frame(width: 28, height: 28)

                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Text(instruction)
                            .font(.body)
                            .padding(.top, 2)
                    }
                }
            }
        }
    }
}

// MARK: - Nutrition Section

struct NutritionSection: View {
    let nutrition: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Nutrition", systemImage: "chart.pie")
                .font(.headline)

            Text(nutrition)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Notes Section

struct NotesSection: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)

            Text(notes)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - QR Code View

struct QRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    let recipe: Recipe

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Scan to view recipe")
                    .font(.headline)

                if let qrURL = recipe.qrCodeURL {
                    AsyncImage(url: qrURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        case .empty:
                            ProgressView()
                                .frame(width: 300, height: 300)
                        case .failure:
                            Image(systemName: "qrcode")
                                .font(.system(size: 100))
                                .foregroundStyle(.secondary)
                                .frame(width: 300, height: 300)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                Text(recipe.recipeURL.absoluteString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView(
            "Unable to load recipe",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
        .overlay(alignment: .bottom) {
            Button("Retry") {
                retry()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}
