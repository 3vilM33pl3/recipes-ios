import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RecipeListViewModel?
    @State private var showUpload = false
    @State private var searchText = ""
    @State private var showFilter = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredRecipes) { recipe in
                                NavigationLink(value: recipe.slug) {
                                    RecipeGridItem(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }

                            if viewModel.hasMorePages {
                                ProgressView()
                                    .gridCellColumns(2)
                                    .onAppear {
                                        Task {
                                            await viewModel.loadNextPage()
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                    .searchable(text: $searchText, prompt: "Search recipes")
                    .onChange(of: searchText) { _, newValue in
                        viewModel.search(query: newValue)
                    }
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: String.self) { slug in
                RecipeDetailView(slug: slug)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showFilter.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showUpload = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showUpload) {
                UploadView()
            }
            .sheet(isPresented: $showFilter) {
                if let viewModel = viewModel {
                    FilterView(filterOptions: viewModel.filterOptions) { options in
                        Task {
                            await viewModel.applyFilter(options)
                        }
                    }
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = RecipeListViewModel(modelContext: modelContext)
                    await viewModel?.loadRecipes()
                }
            }
        }
    }
}

#Preview {
    RecipeListView()
        .modelContainer(PersistenceController.preview.container)
}
