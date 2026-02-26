
import CoreML
import UIKit

func imageToMultiArray(image: UIImage) -> MLMultiArray? {
    let size = CGSize(width: 48, height: 48)

    // UIGraphicsImageRenderer.image { image.draw(in:) } automatically applies
    // imageOrientation — using cgImage directly does not.
    let renderer = UIGraphicsImageRenderer(size: size)
    let oriented = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: size))
    }

    guard let cgImage = oriented.cgImage else { return nil }

    guard let context = CGContext(
        data: nil,
        width: 48,
        height: 48,
        bitsPerComponent: 8,
        bytesPerRow: 48,
        space: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGImageAlphaInfo.none.rawValue
    ) else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 48, height: 48))
    guard let pixelData = context.data else { return nil }

    guard let array = try? MLMultiArray(shape: [1, 48, 48, 1], dataType: .float16) else {
        return nil
    }

    for y in 0..<48 {
        for x in 0..<48 {
            let pixel = pixelData.load(fromByteOffset: y * 48 + x, as: UInt8.self)
            array[[0, y, x, 0] as [NSNumber]] = NSNumber(value: Float(pixel) / 255.0)
        }
    }

    return array
}
