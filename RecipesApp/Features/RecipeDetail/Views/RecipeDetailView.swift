import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecipeDetailViewModel?
    @State private var showQRCode = false
    @State private var showShareSheet = false

    let slug: String

    var body: some View {
        ScrollView {
            if let recipe = viewModel?.recipe {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    RecipeHeaderView(recipe: recipe)

                    Divider()

                    // Metadata
                    if recipe.prepTime != nil || recipe.cookTime != nil || recipe.servings != nil {
                        RecipeMetadataView(recipe: recipe)
                        Divider()
                    }

                    // Ingredients
                    if !recipe.ingredients.isEmpty {
                        IngredientsSection(ingredients: recipe.ingredients)
                        Divider()
                    }

                    // Instructions
                    if !recipe.instructions.isEmpty {
                        InstructionsSection(instructions: recipe.instructions)
                        Divider()
                    }

                    // Nutrition
                    if let nutrition = recipe.nutrition {
                        NutritionSection(nutrition: nutrition)
                        Divider()
                    }

                    // Notes
                    if let notes = recipe.notes {
                        NotesSection(notes: notes)
                        Divider()
                    }

                    // Original Image (zoomable)
                    if let originalImageURL = recipe.originalImageURL {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Original Photo")
                                    .font(.headline)
                                Spacer()
                                Text("Tap to zoom")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            ZoomableImageView(url: originalImageURL)
                                .clipShape(RoundedRectangle(cornerRadius: Configuration.cornerRadius))
                        }
                    }
                }
                .padding()
            } else if viewModel?.isLoading == true {
                ProgressView("Loading recipe...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel?.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel?.loadRecipe()
                    }
                }
            }
        }
        .navigationTitle(viewModel?.recipe?.title ?? "Recipe")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showQRCode = true
                } label: {
                    Image(systemName: "qrcode")
                }

                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }

                Menu {
                    Button(role: .destructive) {
                        viewModel?.showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showQRCode) {
            if let recipe = viewModel?.recipe {
                QRCodeView(recipe: recipe)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let items = viewModel?.shareRecipe() {
                ShareSheet(items: items)
            }
        }
        .alert("Delete Recipe?", isPresented: Binding(
            get: { viewModel?.showDeleteConfirmation ?? false },
            set: { if !$0 { viewModel?.showDeleteConfirmation = false } }
        )) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel?.deleteRecipe()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onChange(of: viewModel?.didDelete ?? false) { _, didDelete in
            if didDelete {
                dismiss()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = RecipeDetailViewModel(slug: slug, modelContext: modelContext)
                await viewModel?.loadRecipe()
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(slug: "sample-recipe")
            .modelContainer(PersistenceController.preview.container)
    }
}
