# Recipes iOS App

Native iOS application for the Recipes platform (https://recipes.metatao.net).

## Features

- Browse recipes with infinite scroll pagination
- Search recipes by title and ingredients
- Filter by difficulty and sort options
- View detailed recipe information with ingredients and instructions
- Upload recipe photos using camera or photo library
- Share recipes via native share sheet
- Offline support with local caching
- Dark mode support
- VoiceOver accessibility

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+

## Project Setup

1. If you cloned this repo through the parent `homelab` repository, initialize the submodule first:
   ```bash
   git submodule update --init applications/recipes-ios
   ```

2. Open the existing `RecipesApp.xcodeproj` in Xcode.

3. Configure capabilities in Xcode:
   - Go to Signing & Capabilities
   - Enable iCloud (CloudKit, Documents)
   - Enable Background Modes (Background fetch)

4. Verify the privacy descriptions in `Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Take photos of recipes to extract and save them</string>

   <key>NSPhotoLibraryUsageDescription</key>
   <string>Choose recipe photos from your library</string>
   ```

## Architecture

The app follows MVVM architecture with Repository Pattern:

```
App/
├── RecipesApp.swift       # App entry point
└── Configuration.swift    # App configuration

Core/
├── Models/                # Data models (Recipe, APIModels)
├── Networking/            # Network layer (NetworkManager)
├── Persistence/           # SwiftData persistence
└── Services/              # Business logic (RecipeService, HapticService)

Features/
├── RecipeList/           # Recipe list feature
├── RecipeDetail/         # Recipe detail feature
├── Upload/               # Photo upload feature
└── Settings/             # Settings feature

Shared/
├── Views/                # Reusable components
├── Extensions/           # Swift extensions
└── Utilities/            # Helper utilities
```

## Key Components

### Models
- `Recipe` - SwiftData model with Codable support
- `RecipeListResponse` - API response for paginated recipes
- `RecipeUploadResponse` - API response for uploads

### Networking
- `NetworkManager` - Actor-based network client with async/await
- `APIEndpoint` - Enum for API endpoints
- Three-tier caching: Memory → Disk (SwiftData) → Network

### Features
- **RecipeListView** - Grid view with search, filter, and pagination
- **RecipeDetailView** - Detailed recipe view with share and delete
- **UploadView** - Camera and photo library integration
- **CameraView** - Custom camera interface with high-quality capture

## API Integration

The app integrates with the backend API at `https://recipes.metatao.net`:

- `GET /api/recipes?page=1&limit=20` - List recipes
- `GET /api/recipes/:slug` - Get recipe details
- `POST /api/recipes` - Upload recipe image
- `DELETE /api/recipes/:slug` - Delete recipe
- `GET /api/recipes/:slug/qr` - Get QR code

## Building & Running

1. Open `RecipesApp.xcodeproj` in Xcode
2. Select a target device (iPhone simulator or physical device)
3. Press Cmd+R to build and run

## Troubleshooting

- If Xcode reports that `project.pbxproj` is missing, the `applications/recipes-ios` submodule is usually not initialized correctly. From the parent `homelab` repo, run:
  ```bash
  git submodule update --init applications/recipes-ios
  ```

## Testing

Run tests with:
```bash
# Unit tests
Cmd+U in Xcode

# UI tests
Product > Test (or Cmd+U with UI test target)
```

## Deployment

### TestFlight

1. Archive the app: Product > Archive
2. Upload to App Store Connect
3. Submit to TestFlight for testing

### App Store

1. Create app listing in App Store Connect
2. Upload build from TestFlight
3. Submit for App Review

## Configuration

Edit `Configuration.swift` to change:
- API base URL
- Pagination settings
- Cache settings
- Image compression quality

## Notes

- The app requires an active internet connection for initial data fetch
- Offline mode uses cached data from SwiftData
- Images are cached automatically by URLCache
- High-quality camera capture is enabled for iPhone Pro models
- iCloud sync is enabled for cross-device recipe access

## License

See main repository LICENSE file.
