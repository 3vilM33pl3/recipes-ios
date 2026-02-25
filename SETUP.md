# iOS Project Setup Instructions

This guide will help you create the Xcode project and integrate the source files.

## Prerequisites

- macOS with Xcode 16.0 or later
- iOS 18.0 SDK
- Apple Developer account (for device testing and App Store submission)

## Step 1: Create Xcode Project

1. Launch Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" platform and "App" template
4. Configure the project:
   - **Product Name**: RecipesApp
   - **Team**: Select your development team
   - **Organization Identifier**: net.metatao (or your own)
   - **Bundle Identifier**: net.metatao.recipes
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: SwiftData
   - **Testing**: Include Tests
5. Choose location: `/Users/olivier/Projects/homelab/applications/recipes-ios/`
6. Uncheck "Create Git repository" (already part of homelab repo)

## Step 2: Configure Project Settings

### General Tab

1. Select the project in the navigator
2. Under "General" tab:
   - **Minimum Deployments**: iOS 18.0
   - **Supported Destinations**: iPhone
   - **Device Orientation**: Portrait, Landscape Left, Landscape Right

### Signing & Capabilities

1. Go to "Signing & Capabilities" tab
2. Enable "Automatically manage signing"
3. Add capabilities:
   - Click "+ Capability"
   - Add "iCloud"
     - Enable "CloudKit"
     - Enable "Key-value storage"
   - Add "Background Modes"
     - Enable "Background fetch"

### Info Tab

1. Add custom iOS target properties:
   - Right-click on Info.plist
   - Add the following keys:

   ```
   NSCameraUsageDescription
   Value: "Take photos of recipes to extract and save them"

   NSPhotoLibraryUsageDescription
   Value: "Choose recipe photos from your library"

   NSSupportsLiveActivities
   Value: YES
   ```

## Step 3: Organize Project Structure

1. In Xcode, delete the default files:
   - `RecipesAppApp.swift` (we have our own)
   - `ContentView.swift` (we have our own)

2. Create folder groups matching the source structure:
   - Right-click on RecipesApp folder
   - Select "New Group"
   - Create these groups:
     - App
     - Core
       - Models
       - Networking
       - Persistence
       - Services
     - Features
       - RecipeList
         - Views
         - ViewModels
       - RecipeDetail
         - Views
         - ViewModels
       - Upload
         - Views
         - ViewModels
       - Settings
         - Views
         - ViewModels
     - Shared
       - Views
       - Extensions
       - Utilities
     - Resources

3. Add source files to groups:
   - Drag files from Finder into corresponding Xcode groups
   - Make sure "Copy items if needed" is UNCHECKED
   - Select "Create groups" (not folder references)
   - Add to RecipesApp target

## Step 4: Add Assets

1. Select `Assets.xcassets` in Xcode
2. Add app icon:
   - Create an App Icon set
   - Add icon images for all required sizes
3. Add colors (optional):
   - Right-click in Assets
   - New Color Set
   - Define custom brand colors

## Step 5: Build Settings

1. Select project in navigator
2. Select RecipesApp target
3. Go to "Build Settings" tab
4. Search for "Swift Language Version"
   - Set to "Swift 6"
5. Search for "Optimization Level"
   - Debug: -Onone
   - Release: -O

## Step 6: Build and Run

1. Select a simulator or connected device
2. Press Cmd+B to build
3. Fix any compilation errors
4. Press Cmd+R to run

## Step 7: Test on Device

1. Connect iPhone via USB
2. Select device from scheme selector
3. Press Cmd+R to build and run
4. Trust developer certificate on device if prompted

## Troubleshooting

### Build Errors

**"Cannot find type 'Recipe' in scope"**
- Ensure all files are added to the RecipesApp target
- Check Build Phases > Compile Sources

**"Module 'SwiftData' not found"**
- Verify deployment target is iOS 18.0+
- Clean build folder (Cmd+Shift+K)

**"Failed to register bundle identifier"**
- Change bundle identifier to something unique
- Update in project settings

### Runtime Errors

**"Failed to create ModelContainer"**
- Check SwiftData models are properly configured
- Ensure @Model macro is applied to Recipe class

**"Camera not working"**
- Verify camera usage description in Info.plist
- Check device has camera permission

**"Network requests failing"**
- Verify backend API is running
- Check App Transport Security settings
- Test API endpoint in browser

## Next Steps

1. **Testing**: Run unit tests with Cmd+U
2. **UI Testing**: Create UI test scenarios
3. **Profiling**: Use Instruments to check performance
4. **TestFlight**: Archive and upload to App Store Connect
5. **App Store**: Submit for review

## Additional Configuration

### Custom URL Scheme (Deep Linking)

1. Go to Info tab
2. Add URL Types
3. Configure scheme: `recipes`
4. Identifier: `net.metatao.recipes`

### Push Notifications (Future)

1. Add "Push Notifications" capability
2. Configure APNs certificates in Apple Developer Portal
3. Implement notification handling

### Widgets (Future)

1. Add Widget Extension target
2. Implement widget timeline provider
3. Configure widget sizes and previews

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
