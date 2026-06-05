import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = root.appendingPathComponent("build/icon-options-calm", isDirectory: true)
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

enum CalmIconVariant: String, CaseIterable {
    case quotaPool = "A-quota-pool"
    case calmBattery = "B-calm-battery"
    case reserveOrb = "C-reserve-orb"
    case quietSentinel = "D-quiet-sentinel"

    var title: String {
        switch self {
        case .quotaPool: return "A  Quota Pool"
        case .calmBattery: return "B  Calm Battery"
        case .reserveOrb: return "C  Reserve Orb"
        case .quietSentinel: return "D  Quiet Sentinel"
        }
    }
}

func appRect(in rect: NSRect) -> NSRect {
    rect.insetBy(dx: rect.width * 0.06, dy: rect.height * 0.06)
}

func rounded(_ rect: NSRect, radius: CGFloat? = nil) -> NSBezierPath {
    let value = radius ?? rect.width * 0.225
    return NSBezierPath(roundedRect: rect, xRadius: value, yRadius: value)
}

func drawAppBase(in rect: NSRect, tone: Int) {
    let outer = appRect(in: rect)
    let path = rounded(outer)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -rect.height * 0.018)
    shadow.shadowBlurRadius = rect.height * 0.05
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.17)
    shadow.set()

    let gradients: [[NSColor]] = [
        [
            NSColor(red: 0.98, green: 0.99, blue: 1.00, alpha: 1),
            NSColor(red: 0.87, green: 0.95, blue: 0.98, alpha: 1),
            NSColor(red: 0.60, green: 0.77, blue: 0.96, alpha: 1),
        ],
        [
            NSColor(red: 0.99, green: 1.00, blue: 0.98, alpha: 1),
            NSColor(red: 0.88, green: 0.97, blue: 0.92, alpha: 1),
            NSColor(red: 0.48, green: 0.78, blue: 0.66, alpha: 1),
        ],
        [
            NSColor(red: 0.99, green: 0.99, blue: 1.00, alpha: 1),
            NSColor(red: 0.90, green: 0.93, blue: 1.00, alpha: 1),
            NSColor(red: 0.62, green: 0.66, blue: 0.96, alpha: 1),
        ],
        [
            NSColor(red: 0.98, green: 1.00, blue: 1.00, alpha: 1),
            NSColor(red: 0.88, green: 0.96, blue: 0.97, alpha: 1),
            NSColor(red: 0.44, green: 0.72, blue: 0.84, alpha: 1),
        ],
    ]
    let colors = gradients[tone % gradients.count]
    NSGradient(colorsAndLocations:
        (colors[0], 0.0),
        (colors[1], 0.50),
        (colors[2], 1.0)
    )!.draw(in: path, angle: 138)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    path.addClip()

    let lowerGlow = NSGradient(colors: [
        NSColor(red: 0.12, green: 0.78, blue: 0.62, alpha: 0.0),
        NSColor(red: 0.12, green: 0.78, blue: 0.62, alpha: 0.24),
    ])!
    lowerGlow.draw(in: outer.insetBy(dx: -rect.width * 0.05, dy: -rect.height * 0.13), angle: 88)

    let sheen = rounded(outer.insetBy(dx: rect.width * 0.034, dy: rect.height * 0.034))
    NSColor.white.withAlphaComponent(0.24).setFill()
    sheen.fill()

    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.74).setStroke()
    path.lineWidth = max(1, rect.width * 0.016)
    path.stroke()
}

func drawLiquidFill(in container: NSRect, fillHeight: CGFloat, colorA: NSColor, colorB: NSColor) {
    let fillRect = NSRect(
        x: container.minX,
        y: container.minY,
        width: container.width,
        height: container.height * fillHeight
    )
    let fillPath = rounded(fillRect, radius: container.width * 0.09)
    NSGradient(colorsAndLocations:
        (colorA, 0.0),
        (colorB, 1.0)
    )!.draw(in: fillPath, angle: 8)

    let wave = NSBezierPath()
    wave.move(to: NSPoint(x: fillRect.minX + fillRect.width * 0.10, y: fillRect.maxY - fillRect.height * 0.17))
    wave.curve(
        to: NSPoint(x: fillRect.maxX - fillRect.width * 0.10, y: fillRect.maxY - fillRect.height * 0.15),
        controlPoint1: NSPoint(x: fillRect.minX + fillRect.width * 0.35, y: fillRect.maxY + fillRect.height * 0.09),
        controlPoint2: NSPoint(x: fillRect.minX + fillRect.width * 0.66, y: fillRect.maxY - fillRect.height * 0.34)
    )
    wave.lineWidth = max(1, container.width * 0.035)
    wave.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.55).setStroke()
    wave.stroke()
}

func drawQuotaPool(in rect: NSRect) {
    let outer = appRect(in: rect)
    let pool = NSRect(
        x: outer.minX + outer.width * 0.23,
        y: outer.minY + outer.height * 0.19,
        width: outer.width * 0.54,
        height: outer.height * 0.55
    )
    let poolPath = rounded(pool, radius: pool.width * 0.12)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -rect.height * 0.014)
    shadow.shadowBlurRadius = rect.height * 0.035
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.13)
    shadow.set()
    NSColor.white.withAlphaComponent(0.44).setFill()
    poolPath.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    poolPath.addClip()
    drawLiquidFill(
        in: pool.insetBy(dx: rect.width * 0.028, dy: rect.height * 0.028),
        fillHeight: 0.70,
        colorA: NSColor(red: 0.15, green: 0.78, blue: 0.50, alpha: 1),
        colorB: NSColor(red: 0.16, green: 0.66, blue: 0.95, alpha: 1)
    )
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.78).setStroke()
    poolPath.lineWidth = max(1, rect.width * 0.014)
    poolPath.stroke()

    let calmLine = NSBezierPath()
    calmLine.move(to: NSPoint(x: pool.minX + pool.width * 0.28, y: pool.maxY + outer.height * 0.08))
    calmLine.line(to: NSPoint(x: pool.maxX - pool.width * 0.28, y: pool.maxY + outer.height * 0.08))
    calmLine.lineWidth = max(2, rect.width * 0.025)
    calmLine.lineCapStyle = .round
    NSColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 0.58).setStroke()
    calmLine.stroke()

    let baseLine = NSBezierPath()
    baseLine.move(to: NSPoint(x: outer.minX + outer.width * 0.28, y: outer.minY + outer.height * 0.15))
    baseLine.line(to: NSPoint(x: outer.maxX - outer.width * 0.28, y: outer.minY + outer.height * 0.15))
    baseLine.lineWidth = max(2, rect.width * 0.020)
    baseLine.lineCapStyle = .round
    NSColor.black.withAlphaComponent(0.16).setStroke()
    baseLine.stroke()
}

func drawCalmBattery(in rect: NSRect) {
    let outer = appRect(in: rect)
    let battery = NSRect(
        x: outer.minX + outer.width * 0.18,
        y: outer.midY - outer.height * 0.15,
        width: outer.width * 0.60,
        height: outer.height * 0.30
    )
    let cap = NSRect(
        x: battery.maxX + outer.width * 0.025,
        y: battery.midY - battery.height * 0.22,
        width: outer.width * 0.06,
        height: battery.height * 0.44
    )
    let body = rounded(battery, radius: battery.height / 2)

    NSColor.white.withAlphaComponent(0.46).setFill()
    body.fill()
    NSColor.white.withAlphaComponent(0.46).setFill()
    rounded(cap, radius: cap.height / 2).fill()

    let fill = battery.insetBy(dx: rect.width * 0.026, dy: rect.height * 0.026)
    let fillPath = NSBezierPath(
        roundedRect: NSRect(x: fill.minX, y: fill.minY, width: fill.width * 0.78, height: fill.height),
        xRadius: fill.height / 2,
        yRadius: fill.height / 2
    )
    NSGradient(colorsAndLocations:
        (NSColor(red: 0.17, green: 0.78, blue: 0.48, alpha: 1), 0.0),
        (NSColor(red: 0.13, green: 0.69, blue: 0.92, alpha: 1), 1.0)
    )!.draw(in: fillPath, angle: 0)

    NSColor.white.withAlphaComponent(0.78).setStroke()
    body.lineWidth = max(1, rect.width * 0.014)
    body.stroke()

    let check = NSBezierPath()
    check.move(to: NSPoint(x: outer.minX + outer.width * 0.34, y: outer.maxY - outer.height * 0.31))
    check.line(to: NSPoint(x: outer.minX + outer.width * 0.45, y: outer.maxY - outer.height * 0.42))
    check.line(to: NSPoint(x: outer.minX + outer.width * 0.67, y: outer.maxY - outer.height * 0.24))
    check.lineWidth = max(3, rect.width * 0.044)
    check.lineCapStyle = .round
    check.lineJoinStyle = .round
    NSColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 0.78).setStroke()
    check.stroke()

    for offset in [0.35, 0.50, 0.65] {
        NSColor.white.withAlphaComponent(0.72).setFill()
        let dot = NSRect(
            x: outer.minX + outer.width * CGFloat(offset) - rect.width * 0.018,
            y: outer.minY + outer.height * 0.20,
            width: rect.width * 0.036,
            height: rect.height * 0.036
        )
        NSBezierPath(ovalIn: dot).fill()
    }
}

func drawReserveOrb(in rect: NSRect) {
    let outer = appRect(in: rect)
    let orbRect = NSRect(
        x: outer.minX + outer.width * 0.23,
        y: outer.minY + outer.height * 0.22,
        width: outer.width * 0.54,
        height: outer.height * 0.54
    )
    let center = NSPoint(x: orbRect.midX, y: orbRect.midY)
    let radius = orbRect.width / 2

    let orb = NSBezierPath(ovalIn: orbRect)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -rect.height * 0.014)
    shadow.shadowBlurRadius = rect.height * 0.04
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.14)
    shadow.set()
    NSGradient(colorsAndLocations:
        (NSColor.white.withAlphaComponent(0.58), 0.0),
        (NSColor(red: 0.83, green: 0.95, blue: 1.00, alpha: 0.50), 1.0)
    )!.draw(in: orb, angle: 135)
    NSGraphicsContext.restoreGraphicsState()

    let ringTrack = NSBezierPath()
    ringTrack.appendArc(withCenter: center, radius: radius * 0.78, startAngle: 0, endAngle: 360)
    ringTrack.lineWidth = max(3, rect.width * 0.050)
    NSColor.white.withAlphaComponent(0.50).setStroke()
    ringTrack.stroke()

    let ring = NSBezierPath()
    ring.appendArc(withCenter: center, radius: radius * 0.78, startAngle: 210, endAngle: -18, clockwise: true)
    ring.lineWidth = ringTrack.lineWidth
    ring.lineCapStyle = .round
    NSColor(red: 0.14, green: 0.74, blue: 0.90, alpha: 1).setStroke()
    ring.stroke()

    NSColor(red: 0.12, green: 0.74, blue: 0.47, alpha: 1).setFill()
    NSBezierPath(
        ovalIn: NSRect(
            x: center.x - rect.width * 0.038,
            y: center.y - rect.height * 0.038,
            width: rect.width * 0.076,
            height: rect.height * 0.076
        )
    ).fill()

    let base = NSBezierPath()
    base.move(to: NSPoint(x: outer.minX + outer.width * 0.30, y: outer.minY + outer.height * 0.17))
    base.line(to: NSPoint(x: outer.maxX - outer.width * 0.30, y: outer.minY + outer.height * 0.17))
    base.lineWidth = max(2, rect.width * 0.023)
    base.lineCapStyle = .round
    NSColor.black.withAlphaComponent(0.16).setStroke()
    base.stroke()
}

func drawQuietSentinel(in rect: NSRect) {
    let outer = appRect(in: rect)
    let panel = NSRect(
        x: outer.minX + outer.width * 0.19,
        y: outer.minY + outer.height * 0.23,
        width: outer.width * 0.62,
        height: outer.height * 0.46
    )
    let panelPath = rounded(panel, radius: panel.width * 0.09)
    NSColor.white.withAlphaComponent(0.42).setFill()
    panelPath.fill()
    NSColor.white.withAlphaComponent(0.72).setStroke()
    panelPath.lineWidth = max(1, rect.width * 0.014)
    panelPath.stroke()

    let dot = NSRect(
        x: panel.minX + panel.width * 0.12,
        y: panel.maxY - panel.height * 0.30,
        width: rect.width * 0.072,
        height: rect.height * 0.072
    )
    NSColor(red: 0.13, green: 0.77, blue: 0.45, alpha: 1).setFill()
    NSBezierPath(ovalIn: dot).fill()

    let lines: [(CGFloat, CGFloat, CGFloat)] = [
        (0.31, 0.73, 0.48),
        (0.16, 0.50, 0.72),
        (0.16, 0.29, 0.58),
    ]
    for line in lines {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: panel.minX + panel.width * line.0, y: panel.minY + panel.height * line.1))
        path.line(to: NSPoint(x: panel.minX + panel.width * line.2, y: panel.minY + panel.height * line.1))
        path.lineWidth = max(2, rect.width * 0.025)
        path.lineCapStyle = .round
        NSColor(red: 0.08, green: 0.12, blue: 0.18, alpha: line.1 > 0.65 ? 0.54 : 0.32).setStroke()
        path.stroke()
    }

    let pool = NSRect(
        x: panel.minX + panel.width * 0.16,
        y: panel.minY + panel.height * 0.13,
        width: panel.width * 0.68,
        height: panel.height * 0.12
    )
    NSColor.white.withAlphaComponent(0.52).setFill()
    rounded(pool, radius: pool.height / 2).fill()
    NSColor(red: 0.15, green: 0.74, blue: 0.92, alpha: 1).setFill()
    rounded(NSRect(x: pool.minX, y: pool.minY, width: pool.width * 0.78, height: pool.height), radius: pool.height / 2).fill()
}

func drawIcon(_ variant: CalmIconVariant, pixels: Int) -> NSBitmapImageRep {
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

    drawAppBase(in: rect, tone: CalmIconVariant.allCases.firstIndex(of: variant) ?? 0)
    switch variant {
    case .quotaPool: drawQuotaPool(in: rect)
    case .calmBattery: drawCalmBattery(in: rect)
    case .reserveOrb: drawReserveOrb(in: rect)
    case .quietSentinel: drawQuietSentinel(in: rect)
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func writePNG(_ rep: NSBitmapImageRep, to url: URL) throws {
    guard let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "QuotaRadarCalmIcons", code: 1)
    }
    try data.write(to: url)
}

func drawContactSheet() throws {
    let cellSize = 420
    let labelHeight = 54
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

    for (index, variant) in CalmIconVariant.allCases.enumerated() {
        let column = index % 2
        let row = index / 2
        let x = margin + column * (cellSize + margin)
        let y = height - margin - (row + 1) * (cellSize + labelHeight) - row * margin

        let icon = drawIcon(variant, pixels: cellSize)
        icon.draw(in: NSRect(x: x, y: y + labelHeight, width: cellSize, height: cellSize))
        variant.title.draw(
            in: NSRect(x: x, y: y + 8, width: cellSize, height: labelHeight - 12),
            withAttributes: attributes
        )
    }

    NSGraphicsContext.restoreGraphicsState()
    try writePNG(rep, to: outputURL.appendingPathComponent("contact-sheet.png"))
}

for variant in CalmIconVariant.allCases {
    try writePNG(drawIcon(variant, pixels: 1024), to: outputURL.appendingPathComponent("\(variant.rawValue)-1024.png"))
    try writePNG(drawIcon(variant, pixels: 256), to: outputURL.appendingPathComponent("\(variant.rawValue)-256.png"))
}

try drawContactSheet()
print("Generated calm icon options in \(outputURL.path)")
