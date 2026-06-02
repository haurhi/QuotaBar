import SwiftUI

// MARK: - Glass Card View

struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .background(
                GlassBackground()
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

struct GlassBackground: View {
    var body: some View {
        ZStack {
            // 背景模糊
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)

            // 微妙渐变覆盖
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

// MARK: - Provider Icon (Custom Image)

struct ProviderIcon: View {
    let provider: Provider
    let size: CGFloat

    var body: some View {
        if let iconImage = customIcon {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(Color.white.opacity(0.08))

                Image(nsImage: iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(size * 0.08)
            }
            .frame(width: size, height: size)
        } else {
            // Fallback to SF Symbol if custom icon not found
            Image(systemName: provider.icon)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .fill(provider.color.gradient)
                        .shadow(color: provider.color.opacity(0.4), radius: 4, x: 0, y: 2)
                )
        }
    }

    private var customIcon: NSImage? {
        if let icon = NSImage(named: provider.iconAssetName) {
            return icon
        }

        let folderName = provider.iconAssetName.replacingOccurrences(of: "ProviderIcons/", with: "")
        let subdirectory = "Assets.xcassets/ProviderIcons/\(folderName).iconset"
        guard let url = Bundle.module.url(
            forResource: "icon_32x32@2x",
            withExtension: "png",
            subdirectory: subdirectory
        ) else {
            return nil
        }
        return NSImage(contentsOf: url)
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat

    private var normalizedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            // 进度圆环
            Circle()
                .trim(from: 0, to: normalizedProgress)
                .stroke(
                    color.gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: normalizedProgress)
        }
    }
}

// MARK: - Usage Bar

struct UsageBar: View {
    let percentage: Double
    let color: Color

    private var normalized: Double {
        min(max(percentage, 0), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.1))

                // 进度条
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * normalized)
                    .animation(.easeInOut(duration: 0.5), value: normalized)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Glass Button

struct GlassButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.thinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Refresh Button

struct RefreshButton: View {
    @Binding var isRefreshing: Bool
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(.thinMaterial)
                )
                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                .animation(
                    isRefreshing ?
                        Animation.linear(duration: 1).repeatForever(autoreverses: false) :
                        .default,
                    value: isRefreshing
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isRefreshing || !isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }
}
