import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var statusPanel: NSPanel?
    var statusPanelHostingController: NSHostingController<MenuContentView>?
    var quotaMonitor: QuotaMonitor!
    var settingsWindow: NSWindow?
    var popoverMouseExitTimer: Timer?
    var statusPanelClickMonitor: Any?
    var statusPanelGlobalClickMonitor: Any?
    weak var statusPanelSettingsOverlayButton: StatusPanelSettingsOverlayButton?
    var cancellables = Set<AnyCancellable>()
    private var autoRefreshCancellable: AnyCancellable?
    private var quotaConsumingAutoRefreshCancellable: AnyCancellable?
    private let preferredSettingsContentSize = NSSize(width: 1040, height: 640)
    private let minimumSettingsWindowSize = NSSize(width: 900, height: 600)
    private let statusPanelGap: CGFloat = 6
    private let statusPanelScreenInset: CGFloat = 10

    func applicationDidFinishLaunching(_ notification: Notification) {
        LegacyConfigurationMigrator.migrateUserDefaultsIfNeeded()
        NSApp.setActivationPolicy(.regular)
        clearSwiftUISettingsWindowAutosaveFrame()
        quotaMonitor = QuotaMonitor.shared
        setupStatusBar()
        setupStatusPanel()
        startMonitoring()
        startLanguageMonitoring()
        showManagedSettingsWindowOnLaunch()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusItem?.button else { return }

        let icon = makeStatusBarIcon()
        icon.isTemplate = true
        button.image = icon
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyDown
        button.contentTintColor = .labelColor
        button.toolTip = L10n.t(.apiQuotaTitle)

        // 监听点击
        button.target = self
        button.action = #selector(togglePopover)
    }

    private func makeStatusBarIcon() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()

        drawQuotaCellStatusGlyph(in: NSRect(x: 1.4, y: 4.3, width: 15.0, height: 9.4))

        image.unlockFocus()
        image.accessibilityDescription = L10n.t(.apiQuotaTitle)
        return image
    }

    private func drawQuotaCellStatusGlyph(in rect: NSRect) {
        NSColor.black.setStroke()
        NSColor.black.setFill()

        let body = NSRect(
            x: rect.minX,
            y: rect.minY + rect.height * 0.06,
            width: rect.width * 0.790,
            height: rect.height * 0.880
        )
        let cap = NSRect(
            x: body.maxX + rect.width * 0.070,
            y: body.midY - body.height * 0.210,
            width: rect.width * 0.105,
            height: body.height * 0.420
        )

        let bodyPath = NSBezierPath(roundedRect: body, xRadius: body.height * 0.30, yRadius: body.height * 0.30)
        bodyPath.lineWidth = 1.60
        bodyPath.stroke()

        drawStatusBatteryTerminal(in: cap)
        drawStatusBatteryFill(in: body)
    }

    private func drawStatusBatteryTerminal(in cap: NSRect) {
        NSBezierPath(
            roundedRect: cap,
            xRadius: cap.height * 0.38,
            yRadius: cap.height * 0.38
        ).fill()
    }

    private func drawStatusBatteryFill(in body: NSRect) {
        let fillArea = body.insetBy(dx: body.width * 0.155, dy: body.height * 0.285)
        let fill = NSRect(
            x: fillArea.minX,
            y: fillArea.minY,
            width: fillArea.width * 0.740,
            height: fillArea.height
        )
        NSBezierPath(
            roundedRect: fill,
            xRadius: fill.height * 0.42,
            yRadius: fill.height * 0.42
        ).fill()
    }

    private func setupStatusPanel() {
        let contentView = MenuContentView(monitor: quotaMonitor)
        let hostingController = NSHostingController(rootView: contentView)
        let containerView = StatusPanelContainerView(frame: NSRect(origin: .zero, size: MenuContentView.menuSize))
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.clear.cgColor

        hostingController.view.frame = containerView.bounds
        hostingController.view.autoresizingMask = [.width, .height]
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        containerView.addSubview(hostingController.view)

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: MenuContentView.menuSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = containerView
        panel.setContentSize(MenuContentView.menuSize)
        panel.animationBehavior = .none
        panel.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.isMovable = false
        panel.level = .statusBar
        configureStatusPanelWindowAppearance(window: panel)
        installStatusPanelSettingsOverlay(on: containerView)

        statusPanelHostingController = hostingController
        statusPanel = panel
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if statusPanel?.isVisible == true {
            closeStatusPopover()
        } else {
            showStatusPanel(relativeTo: button)
        }
    }

    private func showStatusPanel(relativeTo button: NSStatusBarButton) {
        guard let panel = statusPanel else { return }

        AIQuoteStore.shared.advance()
        let frame = frameForStatusPanel(relativeTo: button)
        panel.setFrame(frame, display: true)
        configureStatusPanelWindowAppearance(window: panel)
        panel.orderFrontRegardless()
        DispatchQueue.main.async { [weak self] in
            guard let self, let panel = self.statusPanel else { return }
            panel.setFrame(self.frameForStatusPanel(relativeTo: button), display: true)
        }
        startPopoverMouseExitMonitor()
    }

    private func frameForStatusPanel(relativeTo button: NSStatusBarButton) -> NSRect {
        let buttonFrame: NSRect
        if let window = button.window {
            let buttonFrameInWindow = button.convert(button.bounds, to: nil)
            buttonFrame = window.convertToScreen(buttonFrameInWindow)
        } else {
            buttonFrame = NSRect(origin: NSEvent.mouseLocation, size: .zero)
        }

        let screen = button.window?.screen ?? NSScreen.main
        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1512, height: 949)
        let size = MenuContentView.menuSize
        let minX = visibleFrame.minX + statusPanelScreenInset
        let maxX = visibleFrame.maxX - size.width - statusPanelScreenInset
        let preferredX = buttonFrame.midX - MenuContentView.menuSize.width / 2
        let x = min(max(preferredX, minX), maxX)
        let y = visibleFrame.maxY - statusPanelGap - size.height
        return NSRect(x: x, y: y, width: size.width, height: size.height)
    }

    private func configureStatusPanelWindowAppearance(window: NSWindow) {
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    }

    private func installStatusPanelSettingsOverlay(on contentView: NSView) {
        let button = StatusPanelSettingsOverlayButton(frame: statusHeaderSettingsHitRect(in: contentView))
        button.toolTip = L10n.t(.settingsTab)
        button.setAccessibilityLabel(L10n.t(.settingsTab))
        button.actionHandler = { [weak self] in
            self?.openPreferencesFromStatusPopover(destination: .settings)
        }
        statusPanelSettingsOverlayButton = button
        contentView.addSubview(button, positioned: .above, relativeTo: nil)
    }

    private func closeStatusPopover() {
        statusPanel?.orderOut(nil)
        stopPopoverMouseExitMonitor()
        stopStatusPanelClickMonitor()
    }

    private func startPopoverMouseExitMonitor() {
        stopPopoverMouseExitMonitor()
        startStatusPanelClickMonitor()

        let timer = Timer(timeInterval: 0.45, repeats: true) { [weak self] _ in
            self?.closePopoverIfMouseExited()
        }
        timer.tolerance = 0.10
        RunLoop.main.add(timer, forMode: .common)
        popoverMouseExitTimer = timer
    }

    private func stopPopoverMouseExitMonitor() {
        popoverMouseExitTimer?.invalidate()
        popoverMouseExitTimer = nil
    }

    private func startStatusPanelClickMonitor() {
        stopStatusPanelClickMonitor()

        statusPanelClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] event in
            guard let self,
                  let panel = self.statusPanel,
                  let contentView = panel.contentView,
                  panel.isVisible,
                  event.window === panel else {
                return event
            }

            let pointInContent = contentView.convert(event.locationInWindow, from: nil)
            if self.handleStatusPanelSettingsClick(at: pointInContent, in: contentView) {
                return nil
            }

            return event
        }

        statusPanelGlobalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] event in
            guard let self,
                  let panel = self.statusPanel,
                  panel.isVisible else {
                return
            }

            let screenPoint = NSEvent.mouseLocation
            guard panel.frame.contains(screenPoint),
                  let contentView = panel.contentView else {
                return
            }

            let pointInWindow = panel.convertPoint(fromScreen: screenPoint)
            let pointInContent = contentView.convert(pointInWindow, from: nil)
            _ = self.handleStatusPanelSettingsClick(at: pointInContent, in: contentView)
        }
    }

    private func stopStatusPanelClickMonitor() {
        if let statusPanelClickMonitor {
            NSEvent.removeMonitor(statusPanelClickMonitor)
            self.statusPanelClickMonitor = nil
        }
        if let statusPanelGlobalClickMonitor {
            NSEvent.removeMonitor(statusPanelGlobalClickMonitor)
            self.statusPanelGlobalClickMonitor = nil
        }
    }

    @discardableResult
    private func handleStatusPanelSettingsClick(at pointInContent: NSPoint, in contentView: NSView) -> Bool {
        guard statusPanel?.isVisible == true,
              statusHeaderSettingsHitRect(in: contentView).contains(pointInContent) else {
            return false
        }

        openPreferencesFromStatusPopover(destination: .settings)
        return true
    }

    private func statusHeaderSettingsHitRect(in contentView: NSView) -> NSRect {
        let size = MenuContentView.menuSize
        let visualTopRect = NSRect(
            x: size.width - 68,
            y: 10,
            width: 54,
            height: 48
        )

        if contentView.isFlipped {
            return visualTopRect
        }

        return NSRect(
            x: visualTopRect.minX,
            y: size.height - visualTopRect.maxY,
            width: visualTopRect.width,
            height: visualTopRect.height
        )
    }

    private func closePopoverIfMouseExited() {
        guard let panel = statusPanel, panel.isVisible else {
            stopPopoverMouseExitMonitor()
            return
        }

        let mouseLocation = NSEvent.mouseLocation
        let panelFrame = panel.frame
        let buttonFrame: NSRect? = {
            guard let button = statusItem?.button,
                  let window = button.window else { return nil }
            let windowFrame = button.convert(button.bounds, to: nil)
            return window.convertToScreen(windowFrame)
        }()

        let isInsidePopover = panelFrame.insetBy(dx: -10, dy: -10).contains(mouseLocation)
        let isInsideButton = buttonFrame?.insetBy(dx: -10, dy: -8).contains(mouseLocation) == true

        if !isInsidePopover && !isInsideButton {
            closeStatusPopover()
        }
    }

    @MainActor
    private func startMonitoring() {
        configureAutoRefreshTimer()
        AppAppearanceStore.shared.$autoRefreshInterval
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.configureAutoRefreshTimer()
            }
            .store(in: &cancellables)
        configureQuotaConsumingAutoRefreshTimer()
        AppAppearanceStore.shared.$quotaConsumingAutoRefreshInterval
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.configureQuotaConsumingAutoRefreshTimer()
            }
            .store(in: &cancellables)

        // 首次刷新
        quotaMonitor.refreshAll(mode: .automatic)
    }

    private func startLanguageMonitoring() {
        AppLanguageStore.shared.$language
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateLocalizedStatusBarStrings()
            }
            .store(in: &cancellables)
    }

    private func updateLocalizedStatusBarStrings() {
        if let button = statusItem?.button {
            button.toolTip = L10n.t(.apiQuotaTitle)
            button.image?.accessibilityDescription = L10n.t(.apiQuotaTitle)
        }

        statusPanelSettingsOverlayButton?.toolTip = L10n.t(.settingsTab)
        statusPanelSettingsOverlayButton?.setAccessibilityLabel(L10n.t(.settingsTab))
    }

    @MainActor
    private func configureAutoRefreshTimer() {
        autoRefreshCancellable?.cancel()
        autoRefreshCancellable = nil

        guard let interval = AppAppearanceStore.shared.autoRefreshInterval.timeInterval else {
            return
        }

        autoRefreshCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.quotaMonitor.refreshAll(mode: .automatic)
            }
    }

    @MainActor
    private func configureQuotaConsumingAutoRefreshTimer() {
        quotaConsumingAutoRefreshCancellable?.cancel()
        quotaConsumingAutoRefreshCancellable = nil

        guard let interval = AppAppearanceStore.shared.quotaConsumingAutoRefreshInterval.timeInterval else {
            return
        }

        quotaConsumingAutoRefreshCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.quotaMonitor.refreshQuotaConsumingProviders(mode: .quotaConsumingAutomatic)
            }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openPreferences()
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        false
    }

    @objc func openPreferences() {
        openPreferences(destination: .providers)
    }

    func openPreferencesFromStatusPopover(destination: SettingsDestination) {
        closeStatusPopover()
        DispatchQueue.main.async { [weak self] in
            self?.openPreferences(destination: destination)
        }
    }

    func openPreferences(destination: SettingsDestination) {
        SettingsNavigationStore.shared.select(destination)
        clearSwiftUISettingsWindowAutosaveFrame()

        if settingsWindow == nil {
            closeRestoredSettingsWindows()
            let settingsView = SettingsView(monitor: quotaMonitor)
            let controller = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: controller)
            window.title = "Quota Radar Settings"
            window.identifier = NSUserInterfaceItemIdentifier("QuotaRadarMainSettingsWindow")
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.isReleasedWhenClosed = false
            window.isRestorable = false
            window.tabbingMode = .disallowed
            window.delegate = self
            settingsWindow = window
        }

        if let settingsWindow {
            configureSettingsWindow(settingsWindow)
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        if let settingsWindow {
            scheduleSettingsWindowPlacementRecovery(settingsWindow)
        }
    }

    private func showManagedSettingsWindowOnLaunch() {
        DispatchQueue.main.async { [weak self] in
            self?.openPreferences()
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if let settingsWindow, settingsWindow.isVisible {
            scheduleSettingsWindowPlacementRecovery(settingsWindow)
        }
    }

    func windowDidBecomeKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window === settingsWindow else { return }
        scheduleSettingsWindowPlacementRecovery(window)
    }

    private func closeRestoredSettingsWindows() {
        for window in NSApp.windows where window.isVisible && window.styleMask.contains(.titled) {
            window.close()
        }
    }

    private func configureSettingsWindow(_ window: NSWindow) {
        window.minSize = minimumSettingsWindowSize
        window.collectionBehavior.insert(.moveToActiveSpace)

        if window.contentView?.bounds.width ?? 0 < preferredSettingsContentSize.width ||
            window.contentView?.bounds.height ?? 0 < preferredSettingsContentSize.height {
            window.setContentSize(preferredSettingsContentSize)
        }

        keepSettingsWindowOnScreen(window)
    }

    private func clearSwiftUISettingsWindowAutosaveFrame() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "NSWindow Frame com_apple_SwiftUI_Settings_window")
        defaults.removeObject(
            forKey: "NSSplitView Subview Frames com_apple_SwiftUI_Settings_window, SidebarNavigationSplitView"
        )
    }

    private func keepSettingsWindowOnScreen(_ window: NSWindow) {
        forceSettingsWindowOntoPreferredScreen(window)
    }

    private func scheduleSettingsWindowPlacementRecovery(_ window: NSWindow) {
        let delays: [TimeInterval] = [0, 0.15, 0.50]
        for delay in delays {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak window] in
                guard let self, let window else { return }
                self.forceSettingsWindowOntoPreferredScreen(window)
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    private func forceSettingsWindowOntoPreferredScreen(_ window: NSWindow) {
        let visibleFrame = preferredSettingsVisibleFrame().insetBy(dx: 24, dy: 24)
        let currentFrame = window.frame

        let targetSize = NSSize(
            width: min(max(currentFrame.width, minimumSettingsWindowSize.width), visibleFrame.width),
            height: min(max(currentFrame.height, minimumSettingsWindowSize.height), visibleFrame.height)
        )
        let centeredFrame = NSRect(
            x: visibleFrame.midX - targetSize.width / 2,
            y: visibleFrame.midY - targetSize.height / 2,
            width: targetSize.width,
            height: targetSize.height
        )
        window.setFrame(clampedFrame(centeredFrame, to: visibleFrame), display: true)
    }

    private func preferredSettingsVisibleFrame() -> NSRect {
        if let primaryScreen = NSScreen.screens.first(where: { screen in
            screen.frame.minX == 0 && screen.frame.minY == 0
        }), primaryScreen.visibleFrame.width > 0, primaryScreen.visibleFrame.height > 0 {
            return primaryScreen.visibleFrame
        }

        if let positiveScreen = NSScreen.screens.first(where: { screen in
            screen.visibleFrame.minX >= 0 && screen.visibleFrame.minY >= 0
        }) {
            return positiveScreen.visibleFrame
        }

        if let mainScreen = NSScreen.main, mainScreen.visibleFrame.width > 0, mainScreen.visibleFrame.height > 0 {
            return mainScreen.visibleFrame
        }

        let activeDisplayBounds = activeDisplayFrames()
        let preferredBounds = activeDisplayBounds.first { frame in
            frame.minX >= 0 && frame.minY >= 0
        }

        if let preferredBounds, preferredBounds.width > 0, preferredBounds.height > 0 {
            return NSRect(
                x: preferredBounds.minX,
                y: preferredBounds.minY,
                width: preferredBounds.width,
                height: max(1, preferredBounds.height - 33)
            )
        }

        return NSRect(x: 0, y: 0, width: 1512, height: 949)
    }

    private func activeDisplayFrames() -> [CGRect] {
        var displayCount: UInt32 = 0
        guard CGGetActiveDisplayList(0, nil, &displayCount) == .success, displayCount > 0 else {
            return []
        }

        var displays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
        guard CGGetActiveDisplayList(displayCount, &displays, &displayCount) == .success else {
            return []
        }

        return displays
            .prefix(Int(displayCount))
            .map { CGDisplayBounds($0) }
            .filter { $0.width > 0 && $0.height > 0 }
            .sorted { lhs, rhs in
                if lhs.minX == rhs.minX {
                    return lhs.minY > rhs.minY
                }
                return lhs.minX > rhs.minX
            }
    }

    private func clampedFrame(_ frame: NSRect, to visibleFrame: NSRect) -> NSRect {
        var adjusted = frame
        adjusted.size.width = min(adjusted.width, visibleFrame.width)
        adjusted.size.height = min(adjusted.height, visibleFrame.height)
        adjusted.origin.x = min(max(adjusted.minX, visibleFrame.minX), visibleFrame.maxX - adjusted.width)
        adjusted.origin.y = min(max(adjusted.minY, visibleFrame.minY), visibleFrame.maxY - adjusted.height)
        return adjusted
    }
}

final class StatusPanelSettingsOverlayButton: NSButton {
    var actionHandler: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        isBordered = false
        setButtonType(.momentaryChange)
        imagePosition = .noImage
        title = ""
        focusRingType = .none
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        target = self
        action = #selector(performOverlayAction(_:))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isOpaque: Bool {
        false
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        performOverlayAction(self)
    }

    override func performClick(_ sender: Any?) {
        performOverlayAction(sender)
    }

    @objc private func performOverlayAction(_ sender: Any?) {
        actionHandler?()
    }
}

final class StatusPanelContainerView: NSView {
    override var isOpaque: Bool {
        false
    }
}
