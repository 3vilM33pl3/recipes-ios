import Foundation
import SwiftUI
import SwiftData
import UIKit
import Observation

@MainActor
@Observable
class UploadViewModel {
    var previewImage: UIImage?
    var isUploading = false
    var error: Error?
    var uploadSuccess = false
    var uploadedRecipeSlug: String?

    private let recipeService: RecipeService

    init(modelContext: ModelContext) {
        self.recipeService = RecipeService(modelContext: modelContext)
    }

    func setImage(_ image: UIImage) {
        previewImage = image
        error = nil
    }

    func uploadImage() async {
        guard let image = previewImage,
              let imageData = image.jpegData(compressionQuality: Configuration.compressionQuality) else {
            error = APIError.uploadFailed("Invalid image")
            return
        }

        isUploading = true
        error = nil

        do {
            let uploadInfo = try await recipeService.uploadRecipe(imageData)
            uploadedRecipeSlug = uploadInfo.slug
            uploadSuccess = true

            await HapticService.shared.notification(.success)
        } catch {
            self.error = error
            print("Upload failed: \(error)")

            await HapticService.shared.notification(.error)
        }

        isUploading = false
    }

    func reset() {
        previewImage = nil
        isUploading = false
        error = nil
        uploadSuccess = false
        uploadedRecipeSlug = nil
    }
}
