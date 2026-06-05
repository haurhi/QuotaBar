import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = root.appendingPathComponent("build/icon-options-anxiety", isDirectory: true)
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

enum AnxietyIconVariant: String, CaseIterable {
    case reserveVault = "A-reserve-vault"
    case quietStack = "B-quiet-stack"
    case quotaHalo = "C-quota-halo"
    case calmFlow = "D-calm-flow"

    var title: String {
        switch self {
        case .reserveVault: return "A  Reserve Vault"
        case .quietStack: return "B  Quiet Stack"
        case .quotaHalo: return "C  Quota Halo"
        case .calmFlow: return "D  Calm Flow"
        }
    }

    var subtitle: String {
        switch self {
        case .reserveVault: return "stored safety"
        case .quietStack: return "many keys, clear reserves"
        case .quotaHalo: return "calm overview"
        case .calmFlow: return "quota still flowing"
        }
    }
}

func color(_ hex: Int, alpha: CGFloat = 1) -> NSColor {
    NSColor(
        red: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: alpha
    )
}

func appRect(in rect: NSRect) -> NSRect {
    rect.insetBy(dx: rect.width * 0.055, dy: rect.height * 0.055)
}

func rounded(_ rect: NSRect, radius: CGFloat? = nil) -> NSBezierPath {
    let value = radius ?? rect.width * 0.225
    return NSBezierPath(roundedRect: rect, xRadius: value, yRadius: value)
}

func oval(_ center: NSPoint, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
}

func drawLine(from start: NSPoint, to end: NSPoint, width: CGFloat, color: NSColor, cap: NSBezierPath.LineCapStyle = .round) {
    let line = NSBezierPath()
    line.move(to: start)
    line.line(to: end)
    line.lineWidth = width
    line.lineCapStyle = cap
    color.setStroke()
    line.stroke()
}

func drawOuterBase(in rect: NSRect, palette: Int) {
    let outer = appRect(in: rect)
    let outerPath = rounded(outer)

    let palettes: [[NSColor]] = [
        [color(0xf6fbff), color(0xcfe8ff), color(0x6487ff), color(0x223a8f)],
        [color(0xf9fffb), color(0xd8f5e6), color(0x62c99e), color(0x176a73)],
        [color(0xfbfbff), color(0xe1e4ff), color(0x8793f4), color(0x394287)],
        [color(0xf8fdff), color(0xd5f4f5), color(0x58bfd2), color(0x156985)]
    ]
    let p = palettes[palette % palettes.count]

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -rect.height * 0.018)
    shadow.shadowBlurRadius = rect.height * 0.058
    shadow.shadowColor = color(0x0d1630, alpha: 0.20)
    shadow.set()
    NSGradient(colorsAndLocations:
        (p[0], 0.0),
        (p[1], 0.45),
        (p[2], 0.82),
        (p[3], 1.0)
    )!.draw(in: outerPath, angle: 138)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    outerPath.addClip()

    let topGlow = NSGradient(colors: [
        color(0xffffff, alpha: 0.44),
        color(0xffffff, alpha: 0.02)
    ])!
    topGlow.draw(
        in: NSRect(x: outer.minX - outer.width * 0.18, y: outer.midY, width: outer.width * 0.78, height: outer.height * 0.60),
        relativeCenterPosition: NSPoint(x: -0.30, y: 0.20)
    )

    let lowerGlow = NSGradient(colors: [
        color(0x25d895, alpha: 0.00),
        color(0x25d895, alpha: 0.18)
    ])!
    lowerGlow.draw(in: outer.insetBy(dx: -outer.width * 0.15, dy: -outer.height * 0.20), angle: 82)

    let innerSheen = rounded(outer.insetBy(dx: rect.width * 0.035, dy: rect.height * 0.035))
    NSGradient(colors: [
        color(0xffffff, alpha: 0.28),
        color(0xffffff, alpha: 0.05)
    ])!.draw(in: innerSheen, angle: 118)

    NSGraphicsContext.restoreGraphicsState()

    color(0xffffff, alpha: 0.70).setStroke()
    outerPath.lineWidth = max(1.2, rect.width * 0.014)
    outerPath.stroke()
}

func drawGlassPanel(_ panel: NSRect, radius: CGFloat, in rect: NSRect, fillAlpha: CGFloat = 0.44) {
    let path = rounded(panel, radius: radius)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowOffset = NSSize(width: 0, height: -rect.height * 0.010)
    shadow.shadowBlurRadius = rect.height * 0.035
    shadow.shadowColor = color(0x0d1630, alpha: 0.16)
    shadow.set()
    color(0xffffff, alpha: fillAlpha).setFill()
    path.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGradient(colors: [
        color(0xffffff, alpha: 0.32),
        color(0xffffff, alpha: 0.04)
    ])!.draw(in: path, angle: 115)

    color(0xffffff, alpha: 0.66).setStroke()
    path.lineWidth = max(1, rect.width * 0.010)
    path.stroke()
}

func drawReserveFill(_ rect: NSRect, fraction: CGFloat, from: NSColor, to: NSColor) {
    let clippedFraction = max(0.05, min(1.0, fraction))
    let fill = NSRect(x: rect.minX, y: rect.minY, width: rect.width * clippedFraction, height: rect.height)
    let path = rounded(fill, radius: rect.height / 2)
    NSGradient(colorsAndLocations: (from, 0.0), (to, 1.0))!.draw(in: path, angle: 0)

    let shine = NSBezierPath()
    shine.move(to: NSPoint(x: fill.minX + fill.width * 0.12, y: fill.midY + fill.height * 0.18))
    shine.curve(
        to: NSPoint(x: fill.maxX - fill.width * 0.08, y: fill.midY + fill.height * 0.12),
        controlPoint1: NSPoint(x: fill.minX + fill.width * 0.34, y: fill.midY + fill.height * 0.36),
        controlPoint2: NSPoint(x: fill.minX + fill.width * 0.62, y: fill.midY - fill.height * 0.05)
    )
    shine.lineWidth = max(1, rect.height * 0.18)
    shine.lineCapStyle = .round
    color(0xffffff, alpha: 0.42).setStroke()
    shine.stroke()
}

func drawStatusPips(in rect: NSRect, colors: [NSColor]) {
    let spacing = rect.width * 0.20
    let r = rect.width * 0.048
    let startX = rect.midX - spacing
    for (index, pipColor) in colors.enumerated() {
        let center = NSPoint(x: startX + CGFloat(index) * spacing, y: rect.midY)
        color(0xffffff, alpha: 0.62).setFill()
        oval(center, radius: r * 1.75).fill()
        pipColor.setFill()
        oval(center, radius: r).fill()
    }
}

func drawReserveVault(in rect: NSRect) {
    let outer = appRect(in: rect)
    let vault = NSRect(
        x: outer.minX + outer.width * 0.19,
        y: outer.minY + outer.height * 0.23,
        width: outer.width * 0.62,
        height: outer.height * 0.54
    )
    drawGlassPanel(vault, radius: vault.width * 0.14, in: rect, fillAlpha: 0.50)

    let lid = NSRect(
        x: vault.minX + vault.width * 0.22,
        y: vault.maxY - vault.height * 0.18,
        width: vault.width * 0.56,
        height: vault.height * 0.17
    )
    drawLine(
        from: NSPoint(x: lid.minX, y: lid.midY),
        to: NSPoint(x: lid.maxX, y: lid.midY),
        width: rect.width * 0.030,
        color: color(0x1b2b42, alpha: 0.60)
    )

    let reserveTrack = NSRect(
        x: vault.minX + vault.width * 0.16,
        y: vault.minY + vault.height * 0.26,
        width: vault.width * 0.68,
        height: vault.height * 0.19
    )
    color(0x1b2b42, alpha: 0.12).setFill()
    rounded(reserveTrack, radius: reserveTrack.height / 2).fill()
    drawReserveFill(
        reserveTrack.insetBy(dx: rect.width * 0.010, dy: rect.height * 0.010),
        fraction: 0.78,
        from: color(0x30d98b),
        to: color(0x4fb6ff)
    )

    let lockCenter = NSPoint(x: vault.midX, y: vault.minY + vault.height * 0.58)
    color(0x172033, alpha: 0.66).setFill()
    oval(lockCenter, radius: rect.width * 0.038).fill()
    drawLine(
        from: NSPoint(x: lockCenter.x, y: lockCenter.y - rect.height * 0.022),
        to: NSPoint(x: lockCenter.x, y: lockCenter.y - rect.height * 0.070),
        width: rect.width * 0.018,
        color: color(0x172033, alpha: 0.66)
    )

    drawStatusPips(
        in: NSRect(x: vault.minX, y: vault.minY + vault.height * 0.07, width: vault.width, height: vault.height * 0.16),
        colors: [color(0x2fd287), color(0x4f9cff), color(0xf0b94f)]
    )
}

func drawQuietStack(in rect: NSRect) {
    let outer = appRect(in: rect)
    let cardW = outer.width * 0.66
    let cardH = outer.height * 0.21
    let x = outer.midX - cardW / 2
    let yValues = [
        outer.minY + outer.height * 0.56,
        outer.minY + outer.height * 0.39,
        outer.minY + outer.height * 0.22
    ]
    let fillFractions: [CGFloat] = [0.92, 0.74, 0.61]
    let accentColors = [color(0x38d58a), color(0x4fa4ff), color(0x8c7cff)]

    for (index, y) in yValues.enumerated() {
        let card = NSRect(x: x + CGFloat(index) * rect.width * 0.010, y: y, width: cardW, height: cardH)
        drawGlassPanel(card, radius: cardH * 0.26, in: rect, fillAlpha: index == 0 ? 0.56 : 0.42)

        let dotCenter = NSPoint(x: card.minX + card.width * 0.13, y: card.midY + card.height * 0.10)
        color(0xffffff, alpha: 0.70).setFill()
        oval(dotCenter, radius: rect.width * 0.032).fill()
        accentColors[index].setFill()
        oval(dotCenter, radius: rect.width * 0.020).fill()

        let line1 = NSRect(x: card.minX + card.width * 0.23, y: card.midY + card.height * 0.08, width: card.width * 0.45, height: card.height * 0.10)
        color(0x172033, alpha: 0.21).setFill()
        rounded(line1, radius: line1.height / 2).fill()

        let track = NSRect(x: card.minX + card.width * 0.23, y: card.minY + card.height * 0.27, width: card.width * 0.58, height: card.height * 0.13)
        color(0x172033, alpha: 0.12).setFill()
        rounded(track, radius: track.height / 2).fill()
        drawReserveFill(
            track,
            fraction: fillFractions[index],
            from: accentColors[index],
            to: color(0x54d6c6)
        )

        if index == 0 {
            let check = NSBezierPath()
            check.move(to: NSPoint(x: card.maxX - card.width * 0.17, y: card.midY + card.height * 0.03))
            check.line(to: NSPoint(x: card.maxX - card.width * 0.13, y: card.midY - card.height * 0.04))
            check.line(to: NSPoint(x: card.maxX - card.width * 0.07, y: card.midY + card.height * 0.08))
            check.lineWidth = rect.width * 0.018
            check.lineCapStyle = .round
            check.lineJoinStyle = .round
            color(0x163044, alpha: 0.62).setStroke()
            check.stroke()
        }
    }
}

func drawQuotaHalo(in rect: NSRect) {
    let outer = appRect(in: rect)
    let center = NSPoint(x: outer.midX, y: outer.midY + outer.height * 0.03)
    let radius = outer.width * 0.31

    let haloPanel = NSRect(x: center.x - radius * 1.18, y: center.y - radius * 1.18, width: radius * 2.36, height: radius * 2.36)
    drawGlassPanel(haloPanel, radius: haloPanel.width * 0.50, in: rect, fillAlpha: 0.40)

    let track = NSBezierPath()
    track.appendArc(withCenter: center, radius: radius, startAngle: 218, endAngle: -38, clockwise: true)
    track.lineWidth = rect.width * 0.038
    track.lineCapStyle = .round
    color(0x17304a, alpha: 0.14).setStroke()
    track.stroke()

    let reserve = NSBezierPath()
    reserve.appendArc(withCenter: center, radius: radius, startAngle: 218, endAngle: 62, clockwise: true)
    reserve.lineWidth = rect.width * 0.038
    reserve.lineCapStyle = .round
    color(0x36d88b).setStroke()
    reserve.stroke()

    color(0xffffff, alpha: 0.58).setFill()
    oval(center, radius: radius * 0.55).fill()
    color(0x172033, alpha: 0.20).setStroke()
    oval(center, radius: radius * 0.55).lineWidth = max(1, rect.width * 0.009)
    oval(center, radius: radius * 0.55).stroke()

    let pulse = NSBezierPath()
    pulse.move(to: NSPoint(x: center.x - radius * 0.33, y: center.y))
    pulse.line(to: NSPoint(x: center.x - radius * 0.12, y: center.y))
    pulse.line(to: NSPoint(x: center.x - radius * 0.02, y: center.y + radius * 0.18))
    pulse.line(to: NSPoint(x: center.x + radius * 0.11, y: center.y - radius * 0.18))
    pulse.line(to: NSPoint(x: center.x + radius * 0.25, y: center.y))
    pulse.line(to: NSPoint(x: center.x + radius * 0.38, y: center.y))
    pulse.lineWidth = rect.width * 0.023
    pulse.lineCapStyle = .round
    pulse.lineJoinStyle = .round
    color(0x172033, alpha: 0.64).setStroke()
    pulse.stroke()

    drawStatusPips(
        in: NSRect(x: outer.minX + outer.width * 0.24, y: outer.minY + outer.height * 0.18, width: outer.width * 0.52, height: outer.height * 0.12),
        colors: [color(0x2fd287), color(0x2fd287), color(0x4fa4ff)]
    )
}

func drawCalmFlow(in rect: NSRect) {
    let outer = appRect(in: rect)
    let basin = NSRect(
        x: outer.minX + outer.width * 0.17,
        y: outer.minY + outer.height * 0.23,
        width: outer.width * 0.66,
        height: outer.height * 0.47
    )
    drawGlassPanel(basin, radius: basin.width * 0.13, in: rect, fillAlpha: 0.46)

    let clipPath = rounded(basin.insetBy(dx: rect.width * 0.035, dy: rect.height * 0.035), radius: basin.width * 0.10)
    NSGraphicsContext.saveGraphicsState()
    clipPath.addClip()

    let fillRect = NSRect(
        x: basin.minX + rect.width * 0.035,
        y: basin.minY + rect.height * 0.035,
        width: basin.width - rect.width * 0.070,
        height: basin.height * 0.64
    )
    NSGradient(colorsAndLocations:
        (color(0x32d98d), 0.0),
        (color(0x55c9df), 0.58),
        (color(0x6b8cff), 1.0)
    )!.draw(in: fillRect, angle: 12)

    let wave = NSBezierPath()
    wave.move(to: NSPoint(x: fillRect.minX - fillRect.width * 0.05, y: fillRect.maxY - fillRect.height * 0.15))
    wave.curve(
        to: NSPoint(x: fillRect.maxX + fillRect.width * 0.05, y: fillRect.maxY - fillRect.height * 0.12),
        controlPoint1: NSPoint(x: fillRect.minX + fillRect.width * 0.22, y: fillRect.maxY + fillRect.height * 0.12),
        controlPoint2: NSPoint(x: fillRect.minX + fillRect.width * 0.60, y: fillRect.maxY - fillRect.height * 0.30)
    )
    wave.lineWidth = rect.width * 0.030
    wave.lineCapStyle = .round
    color(0xffffff, alpha: 0.62).setStroke()
    wave.stroke()

    NSGraphicsContext.restoreGraphicsState()

    let keyStem = NSRect(
        x: basin.midX - rect.width * 0.012,
        y: basin.maxY + outer.height * 0.015,
        width: rect.width * 0.024,
        height: outer.height * 0.14
    )
    color(0x172033, alpha: 0.60).setFill()
    rounded(keyStem, radius: keyStem.width / 2).fill()
    color(0x172033, alpha: 0.60).setStroke()
    oval(NSPoint(x: basin.midX, y: keyStem.maxY + rect.height * 0.035), radius: rect.width * 0.060).lineWidth = rect.width * 0.020
    oval(NSPoint(x: basin.midX, y: keyStem.maxY + rect.height * 0.035), radius: rect.width * 0.060).stroke()

    let horizon = NSRect(x: basin.minX + basin.width * 0.20, y: basin.minY + basin.height * 0.15, width: basin.width * 0.60, height: rect.height * 0.020)
    color(0xffffff, alpha: 0.55).setFill()
    rounded(horizon, radius: horizon.height / 2).fill()
}

func drawIcon(_ variant: AnxietyIconVariant, pixels: Int) -> NSImage {
    let size = NSSize(width: pixels, height: pixels)
    let image = NSImage(size: size)
    image.lockFocus()

    NSColor.clear.setFill()
    NSRect(origin: .zero, size: size).fill()

    let rect = NSRect(origin: .zero, size: size)
    switch variant {
    case .reserveVault:
        drawOuterBase(in: rect, palette: 1)
        drawReserveVault(in: rect)
    case .quietStack:
        drawOuterBase(in: rect, palette: 0)
        drawQuietStack(in: rect)
    case .quotaHalo:
        drawOuterBase(in: rect, palette: 2)
        drawQuotaHalo(in: rect)
    case .calmFlow:
        drawOuterBase(in: rect, palette: 3)
        drawCalmFlow(in: rect)
    }

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "QuotaRadarIconOptions", code: 1)
    }
    try png.write(to: url)
}

func drawContactSheet() throws {
    let cellSize = 256
    let labelHeight = 72
    let gap = 30
    let columns = AnxietyIconVariant.allCases.count
    let width = columns * cellSize + (columns + 1) * gap
    let height = cellSize + labelHeight + gap * 2

    let sheet = NSImage(size: NSSize(width: width, height: height))
    sheet.lockFocus()
    color(0xf4f6fb).setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()

    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 17, weight: .semibold),
        .foregroundColor: color(0x1f2937)
    ]
    let subtitleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 12, weight: .medium),
        .foregroundColor: color(0x6b7280)
    ]

    for (index, variant) in AnxietyIconVariant.allCases.enumerated() {
        let x = gap + index * (cellSize + gap)
        let icon = drawIcon(variant, pixels: cellSize)
        icon.draw(in: NSRect(x: x, y: gap + labelHeight, width: cellSize, height: cellSize))

        let title = variant.title as NSString
        let titleSize = title.size(withAttributes: titleAttrs)
        title.draw(
            at: NSPoint(x: CGFloat(x) + (CGFloat(cellSize) - titleSize.width) / 2, y: CGFloat(gap + 34)),
            withAttributes: titleAttrs
        )

        let subtitle = variant.subtitle as NSString
        let subtitleSize = subtitle.size(withAttributes: subtitleAttrs)
        subtitle.draw(
            at: NSPoint(x: CGFloat(x) + (CGFloat(cellSize) - subtitleSize.width) / 2, y: CGFloat(gap + 14)),
            withAttributes: subtitleAttrs
        )
    }

    sheet.unlockFocus()
    try writePNG(sheet, to: outputURL.appendingPathComponent("contact-sheet.png"))
}

for variant in AnxietyIconVariant.allCases {
    try writePNG(drawIcon(variant, pixels: 1024), to: outputURL.appendingPathComponent("\(variant.rawValue)-1024.png"))
    try writePNG(drawIcon(variant, pixels: 256), to: outputURL.appendingPathComponent("\(variant.rawValue)-256.png"))
}

try drawContactSheet()
print("Generated quota anxiety icon options in \(outputURL.path)")
