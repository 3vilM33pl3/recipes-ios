#!/usr/bin/env swift

import Foundation
import AppKit

// Create a simple icon using SF Symbols
func createAppIcon() {
    let size: CGFloat = 1024
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()

    // Background gradient
    let gradient = NSGradient(colors: [
        NSColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1.0), // Coral/Orange
        NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)  // Warm Orange
    ])
    gradient?.draw(in: NSRect(x: 0, y: 0, width: size, height: size), angle: 135)

    // Create fork and knife symbol
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: size * 0.5, weight: .medium)
    if let forkKnifeSymbol = NSImage(systemSymbolName: "fork.knife", accessibilityDescription: nil)?
        .withSymbolConfiguration(symbolConfig) {

        // Center the symbol
        let symbolSize = forkKnifeSymbol.size
        let x = (size - symbolSize.width) / 2
        let y = (size - symbolSize.height) / 2

        // Draw white symbol with shadow
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
        shadow.shadowOffset = NSSize(width: 0, height: -4)
        shadow.shadowBlurRadius = 8

        NSGraphicsContext.current?.saveGraphicsState()
        shadow.set()

        forkKnifeSymbol.draw(
            in: NSRect(x: x, y: y, width: symbolSize.width, height: symbolSize.height),
            from: NSRect.zero,
            operation: .sourceOver,
            fraction: 1.0
        )

        NSGraphicsContext.current?.restoreGraphicsState()
    }

    image.unlockFocus()

    // Save as PNG
    if let tiffData = image.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapImage.representation(using: .png, properties: [:]) {

        let outputPath = "RecipesApp/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
        try? pngData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ Icon created at: \(outputPath)")
    }
}

createAppIcon()
