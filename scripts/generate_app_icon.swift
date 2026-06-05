import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resourcesURL = root.appendingPathComponent("QuotaRadar/Resources", isDirectory: true)
let iconsetURL = root.appendingPathComponent("build/QuotaRadar.iconset", isDirectory: true)
let appIconURL = root.appendingPathComponent("QuotaRadar/Assets.xcassets/AppIcon.appiconset", isDirectory: true)

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

func drawMonitorTileBackground(in rect: NSRect, pixels: Int) -> NSBezierPath {
    let size = CGFloat(pixels)
    let outer = rect.insetBy(dx: size * 0.055, dy: size * 0.055)
    let path = rounded(outer, radius: size * 0.205)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.020)
    shadow.shadowBlurRadius = size * 0.055
    shadow.shadowColor = color(0x05070a, alpha: 0.24)
    shadow.set()

    NSGradient(colorsAndLocations:
        (color(0x262b33), 0.00),
        (color(0x1b2028), 0.50),
        (color(0x10141a), 1.00)
    )!.draw(in: path, angle: 90)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    path.addClip()

    let surfaceSheen = NSGradient(colorsAndLocations:
        (color(0xffffff, alpha: 0.16), 0.00),
        (color(0xffffff, alpha: 0.05), 0.46),
        (NSColor.clear, 1.00)
    )!
    surfaceSheen.draw(in: rounded(outer.insetBy(dx: size * 0.028, dy: size * 0.028), radius: size * 0.178), angle: 92)

    let lowerPlate = NSRect(
        x: outer.minX,
        y: outer.minY,
        width: outer.width,
        height: outer.height * 0.42
    )
    color(0x05070a, alpha: 0.14).setFill()
    lowerPlate.fill()

    NSGraphicsContext.restoreGraphicsState()

    path.lineWidth = max(1, size * 0.010)
    color(0xffffff, alpha: 0.13).setStroke()
    path.stroke()

    return path
}

func drawQuotaCellFill(in battery: NSRect, pixels: Int, fraction: CGFloat = 0.72) {
    let size = CGFloat(pixels)
    let inner = battery.insetBy(dx: battery.width * 0.095, dy: battery.height * 0.24)
    let track = rounded(inner, radius: inner.height / 2)

    color(0x111820, alpha: 0.18).setFill()
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
        (color(0x31d77d), 0.00),
        (color(0x3bd5a7), 0.56),
        (color(0x45b8ff), 1.00)
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

    let battery = NSRect(
        x: outer.minX + outer.width * 0.120,
        y: outer.midY - outer.height * 0.175,
        width: outer.width * 0.690,
        height: outer.height * 0.350
    )
    let cap = NSRect(
        x: battery.maxX + outer.width * 0.030,
        y: battery.midY - battery.height * 0.235,
        width: outer.width * 0.074,
        height: battery.height * 0.470
    )
    let batteryPath = rounded(battery, radius: battery.height * 0.35)

    if pixels > 64 {
        NSGraphicsContext.saveGraphicsState()
        let batteryShadow = NSShadow()
        batteryShadow.shadowOffset = NSSize(width: 0, height: -size * 0.012)
        batteryShadow.shadowBlurRadius = size * 0.032
        batteryShadow.shadowColor = color(0x020305, alpha: 0.34)
        batteryShadow.set()
        color(0xf8fbff, alpha: 0.94).setFill()
        batteryPath.fill()
        NSGraphicsContext.restoreGraphicsState()
    } else {
        color(0xf8fbff, alpha: 0.92).setFill()
        batteryPath.fill()
    }

    drawQuotaCellFill(in: battery, pixels: pixels)

    let capPath = rounded(cap, radius: cap.height * 0.34)
    color(0xf8fbff, alpha: 0.86).setFill()
    capPath.fill()

    batteryPath.lineWidth = max(1, size * 0.010)
    color(0xffffff, alpha: pixels > 64 ? 0.32 : 0.24).setStroke()
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

    let backgroundPath = drawMonitorTileBackground(in: rect, pixels: pixels)
    NSGraphicsContext.saveGraphicsState()
    backgroundPath.addClip()
    drawQuotaCell(in: rect, pixels: pixels)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.restoreGraphicsState()

    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "QuotaRadarIcon", code: 1)
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
    resourcesURL.appendingPathComponent("QuotaRadar.icns").path
]
try iconutil.run()
iconutil.waitUntilExit()

if iconutil.terminationStatus != 0 {
    throw NSError(domain: "QuotaRadarIcon", code: Int(iconutil.terminationStatus))
}
