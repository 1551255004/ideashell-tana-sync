import AppKit

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: GenerateAppIcon <source.png> <output.png>\n", stderr)
    exit(2)
}

let sourceURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
guard let source = NSImage(contentsOf: sourceURL) else {
    fputs("Unable to read source icon.\n", stderr)
    exit(1)
}

let size = 1024
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fputs("Unable to create icon bitmap.\n", stderr)
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else { exit(1) }
NSGraphicsContext.current = context
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: size, height: size).fill()

let destination = NSRect(x: 0, y: 0, width: size, height: size)
NSBezierPath(roundedRect: destination, xRadius: 150, yRadius: 150).addClip()

// The generated master includes a small black preview margin around the tile.
// Crop that margin while retaining the selected artwork unchanged.
let inset = source.size.width * 0.0415
let sourceRect = NSRect(
    x: inset,
    y: inset,
    width: source.size.width - inset * 2,
    height: source.size.height - inset * 2
)
source.draw(in: destination, from: sourceRect, operation: .copy, fraction: 1)
context.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Unable to encode icon PNG.\n", stderr)
    exit(1)
}
try png.write(to: outputURL, options: .atomic)
