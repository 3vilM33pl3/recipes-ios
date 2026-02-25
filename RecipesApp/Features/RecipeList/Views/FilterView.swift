import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var options: FilterOptions
    let onApply: (FilterOptions) -> Void

    init(filterOptions: FilterOptions, onApply: @escaping (FilterOptions) -> Void) {
        _options = State(initialValue: filterOptions)
        self.onApply = onApply
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Sort By") {
                    Picker("Sort Order", selection: $options.sortBy) {
                        Text("Newest First").tag(FilterOptions.SortOption.dateNewest)
                        Text("Oldest First").tag(FilterOptions.SortOption.dateOldest)
                        Text("A-Z").tag(FilterOptions.SortOption.titleAZ)
                        Text("Z-A").tag(FilterOptions.SortOption.titleZA)
                    }
                    .pickerStyle(.menu)
                }

                Section("Filter") {
                    Picker("Difficulty", selection: $options.difficulty) {
                        Text("All").tag(nil as String?)
                        Text("Easy").tag("Easy" as String?)
                        Text("Medium").tag("Medium" as String?)
                        Text("Hard").tag("Hard" as String?)
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Button("Reset") {
                        options = FilterOptions()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(options)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    FilterView(filterOptions: FilterOptions()) { _ in }
}
