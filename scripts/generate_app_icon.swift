import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resourcesURL = root.appendingPathComponent("QuotaBar/Resources", isDirectory: true)
let iconsetURL = root.appendingPathComponent("build/QuotaBar.iconset", isDirectory: true)
let appIconURL = root.appendingPathComponent("QuotaBar/Assets.xcassets/AppIcon.appiconset", isDirectory: true)

try FileManager.default.createDirectory(at: resourcesURL, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: appIconURL, withIntermediateDirectories: true)

let sizes = [16, 32, 128, 256, 512]

func color(_ hex: Int, alpha: CGFloat = 1) -> NSColor {
    NSColor(
        red: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: alpha
    )
}

func rounded(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func circle(center: NSPoint, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
}

func drawIconBackground(in rect: NSRect, pixels: Int) -> NSBezierPath {
    let size = CGFloat(pixels)
    let outer = rect.insetBy(dx: size * 0.055, dy: size * 0.055)
    let path = rounded(outer, radius: size * 0.205)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.018)
    shadow.shadowBlurRadius = size * 0.060
    shadow.shadowColor = color(0x0d1730, alpha: 0.20)
    shadow.set()

    NSGradient(colorsAndLocations:
        (color(0xf8fbff), 0.00),
        (color(0xe7f1ff), 0.42),
        (color(0x7896e8), 1.00)
    )!.draw(in: path, angle: 132)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    path.addClip()

    let topGlow = NSGradient(colorsAndLocations:
        (color(0xffffff, alpha: 0.46), 0.00),
        (color(0xffffff, alpha: 0.10), 0.52),
        (NSColor.clear, 1.00)
    )!
    topGlow.draw(
        in: NSBezierPath(ovalIn: NSRect(x: -size * 0.24, y: size * 0.42, width: size * 0.90, height: size * 0.70)),
        relativeCenterPosition: NSPoint(x: -0.20, y: 0.22)
    )

    let glass = rounded(outer.insetBy(dx: size * 0.034, dy: size * 0.034), radius: size * 0.172)
    NSGradient(colorsAndLocations:
        (color(0xffffff, alpha: 0.18), 0.00),
        (color(0xffffff, alpha: 0.03), 1.00)
    )!.draw(in: glass, angle: 122)

    NSGraphicsContext.restoreGraphicsState()

    path.lineWidth = max(1, size * 0.010)
    color(0xffffff, alpha: 0.62).setStroke()
    path.stroke()

    return path
}

func drawGlassPanel(_ panel: NSRect, radius: CGFloat, pixels: Int, fillAlpha: CGFloat = 0.48) {
    let path = rounded(panel, radius: radius)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -CGFloat(pixels) * 0.010)
    shadow.shadowBlurRadius = CGFloat(pixels) * 0.032
    shadow.shadowColor = color(0x122044, alpha: 0.17)
    shadow.set()
    color(0xffffff, alpha: fillAlpha).setFill()
    path.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGradient(colorsAndLocations:
        (color(0xffffff, alpha: 0.34), 0.00),
        (color(0xffffff, alpha: 0.06), 1.00)
    )!.draw(in: path, angle: 116)

    path.lineWidth = max(1, CGFloat(pixels) * 0.010)
    color(0xffffff, alpha: 0.70).setStroke()
    path.stroke()
}

func drawQuotaCellFill(in battery: NSRect, pixels: Int, fraction: CGFloat = 0.72) {
    let size = CGFloat(pixels)
    let inner = battery.insetBy(dx: battery.width * 0.090, dy: battery.height * 0.22)
    let track = rounded(inner, radius: inner.height / 2)

    color(0x172033, alpha: 0.10).setFill()
    track.fill()

    let fillWidth = max(inner.height, inner.width * min(max(fraction, 0.08), 1.00))
    let fill = NSRect(
        x: inner.minX,
        y: inner.minY,
        width: fillWidth,
        height: inner.height
    )

    NSGraphicsContext.saveGraphicsState()
    track.addClip()
    NSGradient(colorsAndLocations:
        (color(0x27d985), 0.00),
        (color(0x41d3aa), 0.42),
        (color(0x5aa8ff), 1.00)
    )!.draw(in: rounded(fill, radius: fill.height / 2), angle: 0)
    NSGraphicsContext.restoreGraphicsState()

    if pixels > 64 {
        let highlight = NSRect(
            x: fill.minX + fill.width * 0.08,
            y: fill.maxY - fill.height * 0.30,
            width: fill.width * 0.76,
            height: max(1, size * 0.010)
        )
        color(0xffffff, alpha: 0.38).setFill()
        rounded(highlight, radius: highlight.height / 2).fill()
    }
}

func drawQuotaCell(in rect: NSRect, pixels: Int) {
    let size = CGFloat(pixels)
    let outer = rect.insetBy(dx: size * 0.055, dy: size * 0.055)

    if pixels <= 64 {
        let battery = NSRect(
            x: outer.minX + outer.width * 0.115,
            y: outer.midY - outer.height * 0.185,
            width: outer.width * 0.68,
            height: outer.height * 0.37
        )
        let cap = NSRect(
            x: battery.maxX + outer.width * 0.026,
            y: battery.midY - battery.height * 0.24,
            width: outer.width * 0.070,
            height: battery.height * 0.48
        )

        color(0xffffff, alpha: 0.84).setFill()
        rounded(battery, radius: battery.height * 0.30).fill()
        color(0xffffff, alpha: 0.78).setFill()
        rounded(cap, radius: cap.height * 0.34).fill()

        drawQuotaCellFill(in: battery, pixels: pixels)
        return
    }

    let battery = NSRect(
        x: outer.minX + outer.width * 0.115,
        y: outer.midY - outer.height * 0.185,
        width: outer.width * 0.68,
        height: outer.height * 0.37
    )
    let cap = NSRect(
        x: battery.maxX + outer.width * 0.026,
        y: battery.midY - battery.height * 0.24,
        width: outer.width * 0.070,
        height: battery.height * 0.48
    )
    let batteryPath = rounded(battery, radius: battery.height * 0.35)

    NSGraphicsContext.saveGraphicsState()
    let batteryShadow = NSShadow()
    batteryShadow.shadowOffset = NSSize(width: 0, height: -size * 0.012)
    batteryShadow.shadowBlurRadius = size * 0.030
    batteryShadow.shadowColor = color(0x122044, alpha: 0.20)
    batteryShadow.set()
    color(0xffffff, alpha: 0.86).setFill()
    batteryPath.fill()
    NSGraphicsContext.restoreGraphicsState()

    drawQuotaCellFill(in: battery, pixels: pixels)

    let capPath = rounded(cap, radius: cap.height * 0.34)
    color(0xffffff, alpha: 0.78).setFill()
    capPath.fill()

    batteryPath.lineWidth = max(1, size * 0.010)
    color(0xffffff, alpha: 0.76).setStroke()
    batteryPath.stroke()
}

func writePNG(size: Int, scale: Int, name: String, directory: URL) throws {
    let pixels = size * scale
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: pixels, height: pixels)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let rect = NSRect(x: 0, y: 0, width: pixels, height: pixels)
    NSColor.clear.setFill()
    rect.fill()

    let backgroundPath = drawIconBackground(in: rect, pixels: pixels)
    NSGraphicsContext.saveGraphicsState()
    backgroundPath.addClip()
    drawQuotaCell(in: rect, pixels: pixels)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.restoreGraphicsState()

    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "QuotaBarIcon", code: 1)
    }
    try png.write(to: directory.appendingPathComponent(name))
}

for size in sizes {
    try writePNG(size: size, scale: 1, name: "icon_\(size)x\(size).png", directory: iconsetURL)
    try writePNG(size: size, scale: 2, name: "icon_\(size)x\(size)@2x.png", directory: iconsetURL)
}

let appIconEntries: [[String: String]] = sizes.flatMap { size in
    [
        [
            "filename": "icon_\(size)x\(size).png",
            "idiom": "mac",
            "scale": "1x",
            "size": "\(size)x\(size)"
        ],
        [
            "filename": "icon_\(size)x\(size)@2x.png",
            "idiom": "mac",
            "scale": "2x",
            "size": "\(size)x\(size)"
        ]
    ]
}

for size in sizes {
    try writePNG(size: size, scale: 1, name: "icon_\(size)x\(size).png", directory: appIconURL)
    try writePNG(size: size, scale: 2, name: "icon_\(size)x\(size)@2x.png", directory: appIconURL)
}

let contents: [String: Any] = [
    "images": appIconEntries,
    "info": [
        "author": "xcode",
        "version": 1
    ]
]
let contentsData = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try contentsData.write(to: appIconURL.appendingPathComponent("Contents.json"))

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = [
    "-c",
    "icns",
    iconsetURL.path,
    "-o",
    resourcesURL.appendingPathComponent("QuotaBar.icns").path
]
try iconutil.run()
iconutil.waitUntilExit()

if iconutil.terminationStatus != 0 {
    throw NSError(domain: "QuotaBarIcon", code: Int(iconutil.terminationStatus))
}
