import UIKit

extension UIImage {
    /// Resize image to fit within maximum dimensions while maintaining aspect ratio
    func resized(maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage? {
        let widthRatio = maxWidth / size.width
        let heightRatio = maxHeight / size.height
        let ratio = min(widthRatio, heightRatio, 1.0)

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Compress image to target size in bytes
    func compressed(toMaxBytes maxBytes: Int, quality: CGFloat = 0.8) -> Data? {
        var compression = quality
        var imageData = self.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }

        return imageData
    }
}
