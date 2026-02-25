#!/bin/bash

echo "🔍 Verifying Xcode Project Setup..."
echo ""

# Check project file
if [ -f "RecipesApp.xcodeproj/project.pbxproj" ]; then
    echo "✅ Xcode project file exists"
else
    echo "❌ Xcode project file missing"
    exit 1
fi

# Check scheme
if [ -f "RecipesApp.xcodeproj/xcshareddata/xcschemes/RecipesApp.xcscheme" ]; then
    echo "✅ Build scheme exists"
else
    echo "❌ Build scheme missing"
    exit 1
fi

# Count Swift files
SWIFT_COUNT=$(find RecipesApp -name "*.swift" | wc -l | tr -d ' ')
echo "✅ Found $SWIFT_COUNT Swift source files"

# Check key files
KEY_FILES=(
    "RecipesApp/App/RecipesApp.swift"
    "RecipesApp/App/Configuration.swift"
    "RecipesApp/Core/Models/Recipe.swift"
    "RecipesApp/Core/Networking/NetworkManager.swift"
    "RecipesApp/Features/RecipeList/Views/RecipeListView.swift"
    "RecipesApp/Features/RecipeDetail/Views/RecipeDetailView.swift"
    "RecipesApp/Features/Upload/Views/UploadView.swift"
    "RecipesApp/Resources/Assets.xcassets/Contents.json"
    "Info.plist"
)

for file in "${KEY_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ Missing: $file"
    fi
done

echo ""
echo "📊 Project Statistics:"
echo "   - Swift files: $SWIFT_COUNT"
echo "   - Project size: $(du -sh RecipesApp.xcodeproj | cut -f1)"
echo "   - Total files: $(find RecipesApp -type f | wc -l | tr -d ' ')"

echo ""
echo "🎯 Next Steps:"
echo "   1. Open RecipesApp.xcodeproj in Xcode (should already be open)"
echo "   2. Select your development team in Signing & Capabilities"
echo "   3. Add iCloud and Background Modes capabilities"
echo "   4. Press Cmd+B to build"
echo "   5. Press Cmd+R to run"
echo ""
echo "📖 See XCODE_PROJECT_READY.md for detailed instructions"
