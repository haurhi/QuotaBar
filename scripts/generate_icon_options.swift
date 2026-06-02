import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = root.appendingPathComponent("build/icon-options", isDirectory: true)
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

enum IconVariant: String, CaseIterable {
    case liquidKey = "A-liquid-key"
    case arcGauge = "B-arc-gauge"
    case searchHalo = "C-search-halo"
    case providerGrid = "D-provider-grid"

    var title: String {
        switch self {
        case .liquidKey: return "A  Liquid Key"
        case .arcGauge: return "B  Arc Gauge"
        case .searchHalo: return "C  Search Halo"
        case .providerGrid: return "D  Provider Grid"
        }
    }
}

func iconRect(in rect: NSRect) -> NSRect {
    rect.insetBy(dx: rect.width * 0.06, dy: rect.height * 0.06)
}

func roundedPath(_ rect: NSRect) -> NSBezierPath {
    NSBezierPath(
        roundedRect: rect,
        xRadius: rect.width * 0.235,
        yRadius: rect.height * 0.235
    )
}

func drawBase(in rect: NSRect, variant: IconVariant) {
    let outer = iconRect(in: rect)
    let path = roundedPath(outer)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -rect.height * 0.018)
    shadow.shadowBlurRadius = rect.height * 0.052
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
    shadow.set()

    let gradient: NSGradient
    switch variant {
    case .liquidKey:
        gradient = NSGradient(colorsAndLocations:
            (NSColor(red: 0.98, green: 0.99, blue: 1.00, alpha: 1), 0.0),
            (NSColor(red: 0.83, green: 0.93, blue: 1.00, alpha: 1), 0.48),
            (NSColor(red: 0.50, green: 0.67, blue: 0.97, alpha: 1), 1.0)
        )!
    case .arcGauge:
        gradient = NSGradient(colorsAndLocations:
            (NSColor(red: 0.99, green: 0.99, blue: 0.96, alpha: 1), 0.0),
            (NSColor(red: 0.88, green: 0.95, blue: 0.92, alpha: 1), 0.44),
            (NSColor(red: 0.20, green: 0.68, blue: 0.56, alpha: 1), 1.0)
        )!
    case .searchHalo:
        gradient = NSGradient(colorsAndLocations:
            (NSColor(red: 1.00, green: 0.99, blue: 0.98, alpha: 1), 0.0),
            (NSColor(red: 0.90, green: 0.91, blue: 1.00, alpha: 1), 0.46),
            (NSColor(red: 0.54, green: 0.44, blue: 0.95, alpha: 1), 1.0)
        )!
    case .providerGrid:
        gradient = NSGradient(colorsAndLocations:
            (NSColor(red: 0.99, green: 0.99, blue: 1.00, alpha: 1), 0.0),
            (NSColor(red: 0.87, green: 0.95, blue: 0.98, alpha: 1), 0.44),
            (NSColor(red: 0.22, green: 0.60, blue: 0.84, alpha: 1), 1.0)
        )!
    }
    gradient.draw(in: path, angle: 138)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    path.addClip()

    let glow = NSGradient(colors: [
        NSColor(red: 0.12, green: 0.78, blue: 0.62, alpha: 0.0),
        NSColor(red: 0.12, green: 0.78, blue: 0.62, alpha: 0.28)
    ])!
    glow.draw(in: outer.insetBy(dx: -rect.width * 0.06, dy: -rect.height * 0.14), angle: 86)

    let highlight = roundedPath(outer.insetBy(dx: rect.width * 0.035, dy: rect.height * 0.035))
    NSColor.white.withAlphaComponent(0.24).setFill()
    highlight.fill()

    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.74).setStroke()
    path.lineWidth = max(1, rect.width * 0.016)
    path.stroke()
}

func drawLiquidKey(in rect: NSRect) {
    let card = iconRect(in: rect).insetBy(dx: rect.width * 0.16, dy: rect.height * 0.17)
    let barRect = NSRect(
        x: card.minX,
        y: card.midY - card.height * 0.16,
        width: card.width,
        height: card.height * 0.32
    )
    let bar = NSBezierPath(
        roundedRect: barRect,
        xRadius: barRect.height / 2,
        yRadius: barRect.height / 2
    )

    NSColor.white.withAlphaComponent(0.42).setFill()
    bar.fill()
    NSGraphicsContext.saveGraphicsState()
    bar.addClip()
    let fill = barRect.insetBy(dx: rect.width * 0.024, dy: rect.height * 0.024)
    NSGradient(colorsAndLocations:
        (NSColor(red: 0.15, green: 0.80, blue: 0.48, alpha: 1), 0.0),
        (NSColor(red: 0.15, green: 0.68, blue: 0.96, alpha: 1), 0.62),
        (NSColor(red: 0.52, green: 0.43, blue: 0.96, alpha: 1), 1.0)
    )!.draw(
        in: NSBezierPath(roundedRect: fill, xRadius: fill.height / 2, yRadius: fill.height / 2),
        angle: 0
    )
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.74).setStroke()
    bar.lineWidth = max(1, rect.width * 0.012)
    bar.stroke()

    let center = NSPoint(x: card.midX - card.width * 0.04, y: card.midY + card.height * 0.13)
    let radius = card.width * 0.145
    let key = NSBezierPath()
    key.appendOval(in: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    key.move(to: NSPoint(x: center.x + radius * 0.74, y: center.y))
    key.line(to: NSPoint(x: center.x + card.width * 0.36, y: center.y))
    key.move(to: NSPoint(x: center.x + card.width * 0.25, y: center.y))
    key.line(to: NSPoint(x: center.x + card.width * 0.25, y: center.y - card.height * 0.08))
    key.move(to: NSPoint(x: center.x + card.width * 0.34, y: center.y))
    key.line(to: NSPoint(x: center.x + card.width * 0.34, y: center.y - card.height * 0.065))
    key.lineWidth = max(2, rect.width * 0.034)
    key.lineCapStyle = .round
    key.lineJoinStyle = .round
    NSColor(red: 0.08, green: 0.11, blue: 0.16, alpha: 0.90).setStroke()
    key.stroke()
}

func drawArcGauge(in rect: NSRect) {
    let outer = iconRect(in: rect)
    let center = NSPoint(x: outer.midX, y: outer.midY - outer.height * 0.035)
    let radius = outer.width * 0.275
    let track = NSBezierPath()
    track.appendArc(withCenter: center, radius: radius, startAngle: 214, endAngle: -34, clockwise: true)
    track.lineWidth = max(3, rect.width * 0.062)
    track.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.46).setStroke()
    track.stroke()

    let progress = NSBezierPath()
    progress.appendArc(withCenter: center, radius: radius, startAngle: 214, endAngle: 38, clockwise: true)
    progress.lineWidth = track.lineWidth
    progress.lineCapStyle = .round
    NSColor(red: 0.10, green: 0.77, blue: 0.45, alpha: 0.98).setStroke()
    progress.stroke()

    let needle = NSBezierPath()
    needle.move(to: center)
    needle.line(to: NSPoint(x: center.x + radius * 0.72, y: center.y + radius * 0.40))
    needle.lineWidth = max(2, rect.width * 0.032)
    needle.lineCapStyle = .round
    NSColor(red: 0.08, green: 0.11, blue: 0.16, alpha: 0.92).setStroke()
    needle.stroke()

    NSColor(red: 0.08, green: 0.11, blue: 0.16, alpha: 0.92).setFill()
    NSBezierPath(ovalIn: NSRect(x: center.x - rect.width * 0.034, y: center.y - rect.height * 0.034, width: rect.width * 0.068, height: rect.height * 0.068)).fill()

    let marker = NSBezierPath()
    marker.move(to: NSPoint(x: outer.midX - outer.width * 0.13, y: outer.maxY - outer.height * 0.28))
    marker.line(to: NSPoint(x: outer.midX + outer.width * 0.13, y: outer.maxY - outer.height * 0.28))
    marker.lineWidth = max(2, rect.width * 0.026)
    marker.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.78).setStroke()
    marker.stroke()
}

func drawSearchHalo(in rect: NSRect) {
    let outer = iconRect(in: rect)
    let center = NSPoint(x: outer.midX - outer.width * 0.035, y: outer.midY + outer.height * 0.035)
    let radius = outer.width * 0.205

    let halo = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    halo.lineWidth = max(3, rect.width * 0.054)
    NSColor.white.withAlphaComponent(0.60).setStroke()
    halo.stroke()

    let coloredHalo = NSBezierPath()
    coloredHalo.appendArc(withCenter: center, radius: radius, startAngle: 210, endAngle: 14, clockwise: true)
    coloredHalo.lineWidth = halo.lineWidth
    coloredHalo.lineCapStyle = .round
    NSColor(red: 0.16, green: 0.73, blue: 0.94, alpha: 0.98).setStroke()
    coloredHalo.stroke()

    let handle = NSBezierPath()
    handle.move(to: NSPoint(x: center.x + radius * 0.68, y: center.y - radius * 0.68))
    handle.line(to: NSPoint(x: center.x + outer.width * 0.30, y: center.y - outer.height * 0.30))
    handle.lineWidth = max(3, rect.width * 0.052)
    handle.lineCapStyle = .round
    NSColor(red: 0.08, green: 0.11, blue: 0.16, alpha: 0.90).setStroke()
    handle.stroke()

    let barRect = NSRect(x: outer.minX + outer.width * 0.22, y: outer.minY + outer.height * 0.19, width: outer.width * 0.56, height: outer.height * 0.075)
    let bar = NSBezierPath(roundedRect: barRect, xRadius: barRect.height / 2, yRadius: barRect.height / 2)
    NSColor.white.withAlphaComponent(0.40).setFill()
    bar.fill()
    NSColor(red: 0.20, green: 0.78, blue: 0.45, alpha: 0.94).setFill()
    let fillRect = NSRect(x: barRect.minX, y: barRect.minY, width: barRect.width * 0.72, height: barRect.height)
    NSBezierPath(roundedRect: fillRect, xRadius: fillRect.height / 2, yRadius: fillRect.height / 2).fill()
}

func drawProviderGrid(in rect: NSRect) {
    let outer = iconRect(in: rect)
    let side = outer.width * 0.17
    let spacing = outer.width * 0.06
    let total = side * 2 + spacing
    let origin = NSPoint(x: outer.midX - total / 2, y: outer.midY - total / 2 + outer.height * 0.035)
    let colors = [
        NSColor(red: 0.16, green: 0.74, blue: 0.46, alpha: 1),
        NSColor(red: 0.18, green: 0.63, blue: 0.96, alpha: 1),
        NSColor(red: 0.57, green: 0.45, blue: 0.96, alpha: 1),
        NSColor(red: 1.00, green: 0.62, blue: 0.22, alpha: 1),
    ]

    for row in 0..<2 {
        for column in 0..<2 {
            let index = row * 2 + column
            let tileRect = NSRect(
                x: origin.x + CGFloat(column) * (side + spacing),
                y: origin.y + CGFloat(1 - row) * (side + spacing),
                width: side,
                height: side
            )
            let tile = NSBezierPath(roundedRect: tileRect, xRadius: side * 0.30, yRadius: side * 0.30)
            colors[index].setFill()
            tile.fill()
            NSColor.white.withAlphaComponent(0.72).setStroke()
            tile.lineWidth = max(1, rect.width * 0.010)
            tile.stroke()
        }
    }

    let line = NSBezierPath()
    line.move(to: NSPoint(x: outer.minX + outer.width * 0.24, y: outer.minY + outer.height * 0.19))
    line.line(to: NSPoint(x: outer.maxX - outer.width * 0.24, y: outer.minY + outer.height * 0.19))
    line.lineWidth = max(2, rect.width * 0.032)
    line.lineCapStyle = .round
    NSColor(red: 0.08, green: 0.11, blue: 0.16, alpha: 0.70).setStroke()
    line.stroke()
}

func drawIcon(variant: IconVariant, pixels: Int) -> NSBitmapImageRep {
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

    drawBase(in: rect, variant: variant)
    switch variant {
    case .liquidKey: drawLiquidKey(in: rect)
    case .arcGauge: drawArcGauge(in: rect)
    case .searchHalo: drawSearchHalo(in: rect)
    case .providerGrid: drawProviderGrid(in: rect)
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func writePNG(_ rep: NSBitmapImageRep, to url: URL) throws {
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "QuotaBarIconOptions", code: 1)
    }
    try data.write(to: url)
}

func drawContactSheet() throws {
    let cellSize = 420
    let labelHeight = 52
    let margin = 28
    let width = margin * 3 + cellSize * 2
    let height = margin * 3 + (cellSize + labelHeight) * 2

    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: width, height: height)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1).setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: NSColor.labelColor,
        .paragraphStyle: paragraph,
    ]

    for (index, variant) in IconVariant.allCases.enumerated() {
        let column = index % 2
        let row = index / 2
        let x = margin + column * (cellSize + margin)
        let y = height - margin - (row + 1) * (cellSize + labelHeight) - row * margin

        let icon = drawIcon(variant: variant, pixels: cellSize)
        icon.draw(in: NSRect(x: x, y: y + labelHeight, width: cellSize, height: cellSize))
        variant.title.draw(
            in: NSRect(x: x, y: y + 8, width: cellSize, height: labelHeight - 12),
            withAttributes: attributes
        )
    }

    NSGraphicsContext.restoreGraphicsState()
    try writePNG(rep, to: outputURL.appendingPathComponent("contact-sheet.png"))
}

for variant in IconVariant.allCases {
    try writePNG(drawIcon(variant: variant, pixels: 1024), to: outputURL.appendingPathComponent("\(variant.rawValue)-1024.png"))
    try writePNG(drawIcon(variant: variant, pixels: 256), to: outputURL.appendingPathComponent("\(variant.rawValue)-256.png"))
}

try drawContactSheet()

print("Generated icon options in \(outputURL.path)")
