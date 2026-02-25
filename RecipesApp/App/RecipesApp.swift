import SwiftUI
import SwiftData

@main
struct RecipesApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(PersistenceController.shared.container)
        }
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var isOnline = true
    @Published var hasLaunchedBefore = false

    init() {
        checkConnectivity()
        hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")

        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

    private func checkConnectivity() {
        // Check network connectivity
        // This would typically use Network framework
        isOnline = true
    }
}

struct ContentView: View {
    var body: some View {
        RecipeListView()
    }
}
