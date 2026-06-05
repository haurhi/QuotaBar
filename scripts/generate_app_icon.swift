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

func drawRadarPulseArc(center: NSPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, lineWidth: CGFloat, strokeColor: NSColor) {
    let path = NSBezierPath()
    path.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle)
    path.lineWidth = lineWidth
    path.lineCapStyle = .round
    strokeColor.setStroke()
    path.stroke()
}

func drawRadarSweep(center: NSPoint, endpoint: NSPoint, lineWidth: CGFloat) {
    let sweep = NSBezierPath()
    sweep.move(to: center)
    sweep.line(to: endpoint)
    sweep.lineWidth = lineWidth
    sweep.lineCapStyle = .round
    color(0x5ef0a4, alpha: 0.92).setStroke()
    sweep.stroke()
}

func drawQuotaRadar(in rect: NSRect, pixels: Int) {
    let size = CGFloat(pixels)
    let outer = rect.insetBy(dx: size * 0.055, dy: size * 0.055)
    let screen = outer.insetBy(dx: outer.width * 0.125, dy: outer.height * 0.125)
    let screenPath = rounded(screen, radius: size * 0.090)

    if pixels > 64 {
        NSGraphicsContext.saveGraphicsState()
        let glyphShadow = NSShadow()
        glyphShadow.shadowOffset = NSSize(width: 0, height: -size * 0.014)
        glyphShadow.shadowBlurRadius = size * 0.036
        glyphShadow.shadowColor = color(0x020305, alpha: 0.34)
        glyphShadow.set()
        color(0xf8fbff, alpha: 0.92).setStroke()
        screenPath.lineWidth = max(1, size * 0.014)
        screenPath.stroke()
        NSGraphicsContext.restoreGraphicsState()
    } else {
        color(0xf8fbff, alpha: 0.88).setStroke()
        screenPath.lineWidth = max(1, size * 0.014)
        screenPath.stroke()
    }

    let center = NSPoint(x: screen.minX + screen.width * 0.36, y: screen.minY + screen.height * 0.38)
    let arcLineWidth = max(1.2, size * 0.026)
    drawRadarPulseArc(
        center: center,
        radius: screen.width * 0.225,
        startAngle: 16,
        endAngle: 124,
        lineWidth: arcLineWidth,
        strokeColor: color(0x5ef0a4, alpha: 0.98)
    )
    drawRadarPulseArc(
        center: center,
        radius: screen.width * 0.390,
        startAngle: 16,
        endAngle: 125,
        lineWidth: arcLineWidth,
        strokeColor: color(0x58b8ff, alpha: 0.92)
    )

    drawRadarSweep(
        center: center,
        endpoint: NSPoint(x: screen.maxX - screen.width * 0.170, y: screen.maxY - screen.height * 0.165),
        lineWidth: max(1.4, size * 0.025)
    )

    NSGradient(colorsAndLocations:
        (color(0x5ef0a4), 0.00),
        (color(0x58b8ff), 1.00)
    )!.draw(in: circle(center: center, radius: max(1.2, size * 0.050)), angle: 35)

    if pixels > 64 {
        let lowerStatus = NSRect(
            x: screen.minX + screen.width * 0.16,
            y: screen.minY + screen.height * 0.15,
            width: screen.width * 0.62,
            height: max(2, size * 0.020)
        )
        color(0xffffff, alpha: 0.28).setFill()
        rounded(lowerStatus, radius: lowerStatus.height / 2).fill()
    }
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
    drawQuotaRadar(in: rect, pixels: pixels)
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
