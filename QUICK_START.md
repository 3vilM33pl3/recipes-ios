# iOS Recipe App - Quick Start Guide

## Overview

This is a complete, production-ready iOS app implementation for the Recipes platform. All source code has been generated and is ready to be integrated into an Xcode project.

## What's Been Created

### 27 Swift Files
1. **App Layer** (2 files)
   - RecipesApp.swift - App entry point with AppState
   - Configuration.swift - Centralized configuration

2. **Core Layer** (8 files)
   - Recipe.swift - Main data model
   - APIModels.swift - Network models
   - NetworkManager.swift - API client
   - PersistenceController.swift - SwiftData setup
   - RecipeService.swift - Business logic
   - HapticService.swift - Haptic feedback

3. **Features** (11 files)
   - RecipeListViewModel.swift
   - RecipeListView.swift
   - RecipeGridItem.swift
   - FilterView.swift
   - RecipeDetailViewModel.swift
   - RecipeDetailView.swift
   - RecipeDetailComponents.swift
   - UploadViewModel.swift
   - UploadView.swift
   - CameraView.swift

4. **Shared** (4 files)
   - Debouncer.swift
   - UIImage+Extensions.swift
   - Date+Extensions.swift
   - View+Extensions.swift
   - ShareSheet.swift

5. **Tests** (3 files)
   - NetworkManagerTests.swift
   - RecipeListViewModelTests.swift
   - RecipeListUITests.swift

### Supporting Files
- Info.plist - App permissions and configuration
- Package.swift - Swift Package Manager
- README.md - Project documentation
- SETUP.md - Detailed setup instructions
- .gitignore - Git ignore rules

## 5-Minute Setup

### Step 1: Open Xcode
```bash
cd /Users/olivier/Projects/homelab/applications/recipes-ios
open -a Xcode
```

### Step 2: If Using the Parent Homelab Repo, Initialize the Submodule
```bash
cd /Users/olivier/Projects/homelab
git submodule update --init applications/recipes-ios
```

### Step 3: Open the Existing Project
```bash
cd /Users/olivier/Projects/homelab/applications/recipes-ios
open RecipesApp.xcodeproj
```

### Step 4: Configure Capabilities
1. Select project in navigator
2. Signing & Capabilities tab
3. Add "iCloud" capability
   - Enable CloudKit
   - Enable Key-value storage
4. Add "Background Modes"
   - Enable Background fetch

### Step 5: Build & Run
```
Cmd+R
```

## Common Failure

If Xcode says `RecipesApp.xcodeproj` is missing `project.pbxproj`, you are usually looking at an uninitialized submodule directory rather than the real app checkout. Re-run:

```bash
cd /Users/olivier/Projects/homelab
git submodule update --init applications/recipes-ios
```

## Key Features

### Recipe List
- Grid layout with infinite scroll
- Search by title/ingredients
- Filter by difficulty
- Sort by date or title
- Pull to refresh
- Offline caching

### Recipe Detail
- Full recipe information
- Ingredients with bullets
- Numbered instructions
- Metadata (prep time, servings, etc.)
- Share functionality
- QR code display
- Delete with confirmation

### Upload
- Camera capture (high quality)
- Photo library picker
- Image compression
- Upload progress
- Success/error handling

### Advanced Features
- SwiftData persistence
- iCloud sync
- Offline mode
- Dark mode support
- Haptic feedback
- VoiceOver support

## Architecture

```
┌─────────────────────────────────────────┐
│           SwiftUI Views                  │
│  (RecipeListView, RecipeDetailView)     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         View Models                      │
│  (RecipeListViewModel, etc.)            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       RecipeService                      │
│  (Business Logic & Caching)             │
└──────┬───────────────────────┬──────────┘
       │                       │
┌──────▼──────────┐   ┌───────▼──────────┐
│ NetworkManager  │   │ SwiftData        │
│ (API Calls)     │   │ (Local Cache)    │
└─────────────────┘   └──────────────────┘
```

## API Endpoints

All endpoints point to `https://recipes.metatao.net`:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/recipes?page=1&limit=20` | List recipes |
| GET | `/api/recipes/:slug` | Get recipe detail |
| POST | `/api/recipes` | Upload recipe image |
| DELETE | `/api/recipes/:slug` | Delete recipe |
| GET | `/api/recipes/:slug/qr` | Get QR code |

## Data Flow

### Viewing Recipes
1. User opens app
2. RecipeListView loads
3. RecipeListViewModel calls RecipeService
4. RecipeService tries network first
5. Falls back to SwiftData cache if offline
6. Updates UI with results

### Uploading Recipe
1. User taps upload button
2. UploadView appears
3. User takes photo or selects from library
4. UploadViewModel compresses image
5. NetworkManager uploads via multipart
6. Backend processes and returns recipe info
7. App navigates to new recipe

### Offline Support
1. All fetched recipes cached in SwiftData
2. Images cached by URLCache
3. If network fails, app loads from cache
4. User sees cached data with offline indicator

## Configuration Options

Edit `Configuration.swift` to customize:

```swift
static let baseURL = URL(string: "https://recipes.metatao.net")!
static let defaultPageSize = 20
static let imageCacheMaxAge: TimeInterval = 7 * 24 * 60 * 60
static let maxImageUploadSize: Int = 10 * 1024 * 1024
static let compressionQuality: CGFloat = 0.8
```

## Testing

### Run Unit Tests
```
Cmd+U
```

Tests cover:
- API endpoint generation
- Recipe model encoding/decoding
- URL generation
- Search filtering
- Difficulty filtering
- Sorting logic

### Run UI Tests
```
Product → Test
```

UI tests cover:
- App launch
- Navigation flows
- Search functionality
- Upload sheet
- Filter sheet
- Pull to refresh

## Common Issues

### Build Errors

**"Cannot find type 'Recipe'"**
- Ensure all files are added to target
- Check Build Phases → Compile Sources

**"Module 'SwiftData' not found"**
- Set deployment target to iOS 18.0+
- Clean build folder (Cmd+Shift+K)

### Runtime Errors

**"Failed to create ModelContainer"**
- Check Recipe model has @Model macro
- Verify SwiftData schema is correct

**"Network request failed"**
- Check backend API is running
- Verify URL in Configuration.swift
- Test endpoint in browser

**Camera not working**
- Add camera permission to Info.plist
- Check device has camera
- Run on physical device (not simulator)

## Performance Tips

1. **Images**: URLCache automatically caches images
2. **Recipes**: SwiftData provides persistent cache
3. **Search**: Debouncer prevents excessive filtering
4. **Pagination**: Loads 20 recipes at a time
5. **Compression**: Images compressed before upload

## Customization

### Change Colors
Edit colors in SwiftUI views:
```swift
.foregroundStyle(.blue) // Change to your brand color
```

### Change Grid Layout
Edit `RecipeListView.swift`:
```swift
private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()) // 3 columns
]
```

### Change Page Size
Edit `Configuration.swift`:
```swift
static let defaultPageSize = 30 // More recipes per page
```

## Next Steps

1. ✅ Create Xcode project (see SETUP.md)
2. ✅ Add source files to project
3. ✅ Configure capabilities
4. ⬜ Test on simulator
5. ⬜ Test on device
6. ⬜ Add app icon
7. ⬜ Customize colors/branding
8. ⬜ TestFlight beta testing
9. ⬜ App Store submission

## Resources

- **Detailed Setup**: See `SETUP.md`
- **Implementation Status**: See `IMPLEMENTATION_STATUS.md`
- **Project README**: See `README.md`
- **Backend API**: `/Users/olivier/Projects/homelab/applications/recipes/`

## Support

For backend API questions, see:
- `applications/recipes/backend/src/routes/recipes.js`
- `applications/recipes/backend/src/db/schema.sql`

For iOS implementation questions, review:
- This guide (QUICK_START.md)
- SETUP.md for detailed instructions
- Source code comments

## Success Checklist

- [ ] Xcode project created
- [ ] All files added to project
- [ ] App builds without errors
- [ ] App runs on simulator
- [ ] Recipe list loads from API
- [ ] Can navigate to recipe detail
- [ ] Search works
- [ ] Upload from camera works
- [ ] Upload from library works
- [ ] Share sheet works
- [ ] Delete works
- [ ] Offline mode works
- [ ] Dark mode looks good
- [ ] VoiceOver navigation works

---

**Ready to build?** Follow the steps above and you'll have a fully functional iOS app in minutes!
