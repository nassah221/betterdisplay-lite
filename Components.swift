import AppKit
import SwiftUI

final class ArrowCursorNSSlider: NSSlider {
    var onEditingChanged: ((Bool) -> Void)?

    override func animation(forKey key: NSAnimatablePropertyKey) -> Any? {
        return nil
    }

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(bounds, cursor: .arrow)
    }

    override func cursorUpdate(with event: NSEvent) {
        NSCursor.arrow.set()
    }

    override func mouseDown(with event: NSEvent) {
        NSCursor.arrow.set()
        onEditingChanged?(true)
        super.mouseDown(with: event)
        NSCursor.arrow.set()
        onEditingChanged?(false)
    }
}

struct NativeLiquidGlassSlider: NSViewRepresentable {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var onEditingChanged: ((Bool) -> Void)?

    final class Coordinator: NSObject {
        var parent: NativeLiquidGlassSlider
        init(_ parent: NativeLiquidGlassSlider) { self.parent = parent }
        @objc func valueChanged(_ sender: NSSlider) {
            NSCursor.arrow.set()
            parent.value = sender.doubleValue
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> ArrowCursorNSSlider {
        let slider = ArrowCursorNSSlider()
        slider.sliderType = .linear
        slider.isContinuous = true
        slider.minValue = range.lowerBound
        slider.maxValue = range.upperBound
        slider.doubleValue = value
        slider.trackFillColor = .white
        slider.target = context.coordinator
        slider.action = #selector(Coordinator.valueChanged(_:))
        slider.onEditingChanged = onEditingChanged
        return slider
    }

    func updateNSView(_ nsView: ArrowCursorNSSlider, context: Context) {
        context.coordinator.parent = self
        nsView.minValue = range.lowerBound
        nsView.maxValue = range.upperBound
        if abs(nsView.doubleValue - value) > 0.0001 {
            nsView.doubleValue = value
        }
        nsView.onEditingChanged = onEditingChanged
    }
}

// MARK: - Design Tokens & Motion Curves

enum CCMotion {
    static var reduceMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    static func easeOut(_ duration: Double) -> Animation {
        .timingCurve(0.23, 1.0, 0.32, 1.0, duration: duration)
    }

    static func easeInOut(_ duration: Double) -> Animation {
        .timingCurve(0.77, 0.0, 0.175, 1.0, duration: duration)
    }

    static let press: Animation = easeOut(0.14)
    static let toggle: Animation = easeOut(0.18)
    static let popoverOpen: Animation = easeOut(0.18)
    static let popoverClose: Animation = easeOut(0.11)

    static var expand: Animation {
        reduceMotion ? .easeOut(duration: 0.14) : .spring(response: 0.24, dampingFraction: 1.0)
    }

    static var collapse: Animation {
        reduceMotion ? .easeOut(duration: 0.11) : .spring(response: 0.18, dampingFraction: 1.0)
    }
}

enum CCTheme {
    static let shellRadius: CGFloat = 16
    static let cardRadius: CGFloat = 12
    static let rowRadius: CGFloat = 8
    static let subRowRadius: CGFloat = 7
    static let segmentRadius: CGFloat = 6
    static let badgeRadius: CGFloat = 4.5

    static let shellFill = Color(red: 0.10, green: 0.11, blue: 0.14).opacity(0.78)
    static let cardFill = Color.white.opacity(0.06)
    static let expandedCardFill = Color(red: 0.11, green: 0.12, blue: 0.15).opacity(0.90)

    static let accentBlue = Color(red: 0.04, green: 0.52, blue: 1.0)
    static let accentSelectionFill = Color(red: 0.04, green: 0.52, blue: 1.0).opacity(0.20)
    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 0.14, green: 0.58, blue: 1.0),
            Color(red: 0.02, green: 0.45, blue: 0.96)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let textPrimary = Color.white.opacity(0.94)
    static let textSecondary = Color.white.opacity(0.72)
    static let textMuted = Color.white.opacity(0.56)

    static func specularBorder(top: Double = 0.26, bottom: Double = 0.06, diagonal: Bool = false) -> LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(top), Color.white.opacity(bottom)],
            startPoint: diagonal ? .topLeading : .top,
            endPoint: diagonal ? .bottomTrailing : .bottom
        )
    }
}

// MARK: - GPU Hover Highlight (AppKit NSTrackingArea, zero @State, zero SwiftUI re-renders)

final class HoverTrackNSView: NSView {
    var cornerRadius: CGFloat = 8
    var hoverOpacity: Double = 0.07
    var isCapsule: Bool = false
    var topCornersOnly: Bool = false
    private var trackingArea: NSTrackingArea?
    private var isHovered: Bool = false

    override var isFlipped: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.opacity = 0
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
        syncHoverWithPointer()
    }

    /// Re-derive hover from the real pointer position. Content often moves under a
    /// stationary cursor after a click (submenu swap, layout change) and AppKit then
    /// never delivers mouseExited, leaving the highlight stuck.
    private func syncHoverWithPointer() {
        guard let window, window.isVisible, window.isKeyWindow else {
            if isHovered { setHovered(false) }
            return
        }
        let p = convert(window.mouseLocationOutsideOfEventStream, from: nil)
        setHovered(bounds.contains(p))
    }

    override func mouseMoved(with event: NSEvent) {
        syncHoverWithPointer()
    }

    override func layout() {
        super.layout()
        guard let layer else { return }
        layer.cornerRadius = isCapsule ? (bounds.height * 0.5) : cornerRadius
        layer.cornerCurve = .continuous
        layer.maskedCorners = topCornersOnly
            ? [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.backgroundColor = NSColor.white.withAlphaComponent(hoverOpacity).cgColor
        syncHoverWithPointer()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window == nil && isHovered {
            isHovered = false
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer?.opacity = 0
            CATransaction.commit()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        setHovered(true)
    }

    override func mouseExited(with event: NSEvent) {
        setHovered(false)
    }

    private func setHovered(_ hovered: Bool) {
        guard isHovered != hovered else { return }
        isHovered = hovered
        guard let layer else { return }
        let targetOpacity: Float = hovered ? 1.0 : 0.0
        if CCMotion.reduceMotion {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.opacity = targetOpacity
            CATransaction.commit()
            return
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(hovered ? 0.10 : 0.08)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.23, 1.0, 0.32, 1.0))
        layer.opacity = targetOpacity
        CATransaction.commit()
    }
}

struct CCHoverOverlay: NSViewRepresentable {
    var cornerRadius: CGFloat = CCTheme.rowRadius
    var hoverOpacity: Double = 0.07
    var isCapsule: Bool = false
    var topCornersOnly: Bool = false

    func makeNSView(context: Context) -> HoverTrackNSView {
        let view = HoverTrackNSView()
        view.cornerRadius = cornerRadius
        view.hoverOpacity = hoverOpacity
        view.isCapsule = isCapsule
        view.topCornersOnly = topCornersOnly
        return view
    }

    func updateNSView(_ nsView: HoverTrackNSView, context: Context) {
        nsView.cornerRadius = cornerRadius
        nsView.hoverOpacity = hoverOpacity
        nsView.isCapsule = isCapsule
        nsView.topCornersOnly = topCornersOnly
        nsView.needsLayout = true
    }
}

// MARK: - Tactile Pointer-Down Button Styles
// NOTE: the SwiftUI State property wrapper / macro plugin is unavailable on this
// toolchain, so these components keep no per-view stored state and rely on
// ButtonStyleConfiguration.isPressed + AppKit NSTrackingArea for hover/press response.

struct CCRowButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = CCTheme.rowRadius

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                ZStack {
                    CCHoverOverlay(cornerRadius: cornerRadius, hoverOpacity: 0.07)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.0))
                }
                .allowsHitTesting(false)
            }
            .scaleEffect(CCMotion.reduceMotion ? 1.0 : (configuration.isPressed ? 0.985 : 1.0))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .animation(CCMotion.press, value: configuration.isPressed)
    }
}

struct CCPillButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                ZStack {
                    CCHoverOverlay(
                        cornerRadius: cornerRadius ?? 0,
                        hoverOpacity: 0.09,
                        isCapsule: cornerRadius == nil
                    )
                    if let cornerRadius {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.0))
                    } else {
                        Capsule()
                            .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.0))
                    }
                }
                .allowsHitTesting(false)
            }
            .scaleEffect(CCMotion.reduceMotion ? 1.0 : (configuration.isPressed ? 0.97 : 1.0))
            .contentShape(Rectangle())
            .animation(CCMotion.press, value: configuration.isPressed)
    }
}

private struct CCExpandableHeaderButtonStyle: ButtonStyle {
    let isExpanded: Bool

    func makeBody(configuration: Configuration) -> some View {
        let headerShape = UnevenRoundedRectangle(
            topLeadingRadius: CCTheme.cardRadius,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: CCTheme.cardRadius,
            style: .continuous
        )
        configuration.label
            .background {
                ZStack {
                    CCHoverOverlay(
                        cornerRadius: isExpanded ? CCTheme.cardRadius : CCTheme.rowRadius,
                        hoverOpacity: isExpanded ? 0.06 : 0.07,
                        topCornersOnly: isExpanded
                    )
                    if !isExpanded {
                        RoundedRectangle(cornerRadius: CCTheme.rowRadius, style: .continuous)
                            .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.0))
                    }
                }
                .allowsHitTesting(false)
            }
            .overlay {
                if isExpanded {
                    headerShape
                        .fill(Color.white.opacity(configuration.isPressed ? 0.08 : 0.0))
                        .allowsHitTesting(false)
                }
            }
            .scaleEffect(CCMotion.reduceMotion || isExpanded ? 1.0 : (configuration.isPressed ? 0.985 : 1.0))
            .contentShape(Rectangle())
            .animation(CCMotion.press, value: configuration.isPressed)
    }
}

// MARK: - Custom Slider

struct CCSlider: View {
    let title: String
    let icon: String
    var hasPaletteBadge: Bool = false
    @Binding var value: Double
    let range: ClosedRange<Double>
    var neutralValue: Double = 0
    var rightLabel: String? = nil
    var showResetButton: Bool = true
    var horizontalPadding: CGFloat = 8
    var onEditingChanged: ((Bool) -> Void)? = nil

    var body: some View {
        let isDirty = showResetButton && abs(value - neutralValue) > 0.005
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11.5, weight: .medium))
                    .tracking(-0.08)
                    .foregroundColor(CCTheme.textPrimary)
                if hasPaletteBadge {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(CCTheme.textMuted)
                }
                Spacer()
                if let rightLabel {
                    Text(rightLabel)
                        .font(.system(size: 10.5, weight: .regular, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(CCTheme.textSecondary)
                }
                if isDirty {
                    Button {
                        value = neutralValue
                        onEditingChanged?(false)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 8.5, weight: .semibold))
                            .foregroundColor(CCTheme.textPrimary)
                            .frame(width: 16, height: 16)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        CCTheme.specularBorder(top: 0.30, bottom: 0.08),
                                        lineWidth: 0.6
                                    )
                            )
                    }
                    .buttonStyle(CCPillButtonStyle())
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                    .help("Reset to neutral")
                }
            }
            .frame(height: 15)
            .animation(CCMotion.press, value: isDirty)

            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(CCTheme.textSecondary)
                    .frame(width: 20, height: 18, alignment: .center)

                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.28), Color.white.opacity(0.14)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Capsule()
                                .fill(Color.white.opacity(0.10))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    CCTheme.specularBorder(top: 0.34, bottom: 0.07),
                                    lineWidth: 0.6
                                )
                        )
                        .shadow(color: Color.black.opacity(0.22), radius: 1, x: 0, y: 0.5)
                        .frame(height: 5)
                        .allowsHitTesting(false)

                    NativeLiquidGlassSlider(
                        value: $value,
                        range: range,
                        onEditingChanged: { editing in
                            if !editing && showResetButton {
                                let snapTol = (range.upperBound - range.lowerBound) * 0.015
                                if abs(value - neutralValue) <= snapTol && value != neutralValue {
                                    value = neutralValue
                                }
                            }
                            onEditingChanged?(editing)
                        }
                    )
                    .frame(height: 20)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
}

// MARK: - Navigation Row

struct CCMenuRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var horizontalPadding: CGFloat = 8
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.86))
                    .frame(width: 20, height: 20, alignment: .center)
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .tracking(-0.05)
                    .foregroundColor(CCTheme.textPrimary)
                Spacer()
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 10.5, weight: .regular))
                        .foregroundColor(CCTheme.textMuted)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .frame(height: 26)
        }
        .buttonStyle(CCRowButtonStyle())
    }
}

// MARK: - Section Hairline Dividers

struct CCSectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.09))
            .frame(height: 1)
            .padding(.horizontal, 10)
            .frame(height: 10, alignment: .center)
            .allowsHitTesting(false)
    }
}

struct CCSubpanelDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.vertical, 3)
            .allowsHitTesting(false)
    }
}

// MARK: - Switch Row

struct CCSwitchRow: View {
    let icon: String
    let title: String
    let isOn: Bool
    var horizontalPadding: CGFloat = 8
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.86))
                    .frame(width: 20, height: 20, alignment: .center)
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .tracking(-0.05)
                    .foregroundColor(CCTheme.textPrimary)
                Spacer()
                ZStack(alignment: isOn ? .trailing : .leading) {
                    Group {
                        if isOn {
                            Capsule()
                                .fill(CCTheme.accentGradient)
                        } else {
                            Capsule()
                                .fill(Color.white.opacity(0.16))
                        }
                    }
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                CCTheme.specularBorder(top: 0.22, bottom: 0.05),
                                lineWidth: 0.6
                            )
                    )
                    Circle()
                        .fill(Color.white)
                        .frame(width: 13, height: 13)
                        .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 0.5)
                        .padding(1)
                }
                .frame(width: 26, height: 15)
                .animation(CCMotion.toggle, value: isOn)
                .allowsHitTesting(false)
            }
            .padding(.horizontal, horizontalPadding)
            .frame(height: 26)
        }
        .buttonStyle(CCRowButtonStyle())
    }
}

// MARK: - Footer Bar

struct CCFooterBar: View {
    let status: String
    let onRefresh: () -> Void
    let onQuit: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(status.isEmpty ? " " : status)
                .font(.system(size: 10.5, weight: .regular))
                .foregroundColor(CCTheme.textMuted)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(status)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.76))
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.white.opacity(0.08)))
                    .overlay(
                        Circle()
                            .strokeBorder(
                                CCTheme.specularBorder(top: 0.20, bottom: 0.05),
                                lineWidth: 0.5
                            )
                    )
            }
            .buttonStyle(CCPillButtonStyle())
            .help("Refresh Displays")

            Button(action: onQuit) {
                Text("Quit")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(CCTheme.textPrimary)
                    .padding(.horizontal, 9)
                    .frame(height: 20)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                CCTheme.specularBorder(top: 0.20, bottom: 0.05),
                                lineWidth: 0.5
                            )
                    )
            }
            .buttonStyle(CCPillButtonStyle())
            .help("Quit DisplayControl (⌘Q)")
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.horizontal, 8)
        .frame(height: 26)
    }
}

// MARK: - Toggle Circle Row

struct CCToggleCircleRow: View {
    var icon: String? = nil
    let title: String
    let isActive: Bool
    var badgeText: String? = nil
    var horizontalPadding: CGFloat = 8
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.white.opacity(isActive ? 0.0 : 0.10))
                    .background {
                        if isActive {
                            Circle()
                                .fill(CCTheme.accentGradient)
                        }
                    }
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle()
                            .strokeBorder(
                                CCTheme.specularBorder(
                                    top: isActive ? 0.48 : 0.18,
                                    bottom: isActive ? 0.10 : 0.05
                                ),
                                lineWidth: 0.75
                            )
                    }
                    .overlay {
                        if let badgeText {
                            Text(badgeText)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(isActive ? .white : Color.white.opacity(0.75))
                        } else if let icon {
                            Image(systemName: icon)
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundColor(isActive ? .white : Color.white.opacity(0.62))
                        }
                    }
                    .shadow(
                        color: isActive ? CCTheme.accentBlue.opacity(0.35) : .clear,
                        radius: isActive ? 4 : 0,
                        x: 0,
                        y: 1
                    )
                    .animation(CCMotion.toggle, value: isActive)
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .tracking(-0.05)
                    .foregroundColor(CCTheme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, horizontalPadding)
            .frame(height: 26)
        }
        .buttonStyle(CCRowButtonStyle())
    }
}

// MARK: - Compact Mode Badge Pill

struct CCModeBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9.5, weight: .medium))
            .monospacedDigit()
            .tracking(0.08)
            .foregroundColor(Color.white.opacity(0.78))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: CCTheme.badgeRadius, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CCTheme.badgeRadius, style: .continuous)
                    .strokeBorder(
                        CCTheme.specularBorder(top: 0.20, bottom: 0.06),
                        lineWidth: 0.6
                    )
            )
    }
}

// MARK: - View Motion Helpers

extension View {
    func exitFade(visible: Bool) -> some View {
        let anim: Animation = visible
            ? (CCMotion.reduceMotion ? CCMotion.easeOut(0.14) : CCMotion.easeOut(0.16).delay(0.03))
            : CCMotion.easeOut(0.08)
        return self.animation(anim) {
            $0.opacity(visible ? 1 : 0)
        }
    }
}

// MARK: - Continuous Sliding Expandable Section (Header slides UP, Body unrolls DOWN, zero alpha-group flicker)

struct CCExpandableSection<BodyContent: View>: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let isExpanded: Bool
    let isHidden: Bool
    let expandedBodyHeight: CGFloat
    let onToggle: () -> Void
    @ViewBuilder let bodyContent: () -> BodyContent

    var body: some View {
        let surfaceAnim = CCMotion.easeOut(isExpanded ? 0.18 : 0.10)
        let contentAnim = CCMotion.easeOut(isExpanded ? 0.18 : 0.09)
        let headerShape = UnevenRoundedRectangle(
            topLeadingRadius: CCTheme.cardRadius,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: CCTheme.cardRadius,
            style: .continuous
        )
        ZStack(alignment: .top) {
            // Bottom Layer: Scrollable/body content spans full card height so items glide beneath the flush-top Liquid Glass header bar
            Color.clear
                .frame(height: isExpanded ? expandedBodyHeight + 34 : 28)
                .overlay(alignment: .top) {
                    bodyContent()
                        .padding(.horizontal, 6)
                        .padding(.bottom, 6)
                        .frame(height: expandedBodyHeight + 34, alignment: .top)
                        .geometryGroup()
                        .animation(contentAnim) {
                            $0.opacity(isExpanded ? 1 : 0)
                                .offset(y: (isExpanded || CCMotion.reduceMotion) ? 0 : -4)
                        }
                }
                .clipped()

            // Top Layer: Flush-top Liquid Glass header bar (zero inset slit, concentric 12pt top corners)
            Button(action: onToggle) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.90))
                        .frame(width: 20, height: 20, alignment: .center)
                    Text(title)
                        .font(.system(size: 12, weight: .regular))
                        .tracking(-0.05)
                        .foregroundColor(Color.white.opacity(isExpanded ? 1.0 : 0.94))
                    Spacer()
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 10.5, weight: .regular))
                            .foregroundColor(CCTheme.textMuted)
                            .animation(CCMotion.easeOut(0.10)) {
                                $0.opacity(isExpanded ? 0 : 1)
                            }
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(Color.white.opacity(isExpanded ? 0.72 : 0.45))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(isExpanded ? CCMotion.expand : CCMotion.collapse, value: isExpanded)
                }
                .padding(.horizontal, 8)
                .frame(height: 28)
                .frame(maxWidth: .infinity)
                .background {
                    ZStack(alignment: .bottom) {
                        headerShape
                            .fill(Color(red: 0.11, green: 0.12, blue: 0.15).opacity(0.68))
                            .glassEffect(.regular.interactive(), in: headerShape)
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 0.5)
                    }
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [Color(red: 0.11, green: 0.12, blue: 0.15).opacity(0.35), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 6)
                        .offset(y: 6)
                    }
                    .animation(surfaceAnim) {
                        $0.opacity(isExpanded ? 1 : 0)
                    }
                    .allowsHitTesting(false)
                }
            }
            .buttonStyle(CCExpandableHeaderButtonStyle(isExpanded: isExpanded))
        }
        .background(
            RoundedRectangle(cornerRadius: CCTheme.cardRadius, style: .continuous)
                .fill(CCTheme.expandedCardFill)
                .animation(surfaceAnim) {
                    $0.opacity(isExpanded ? 1 : 0)
                }
                .allowsHitTesting(false)
        )
        .clipShape(RoundedRectangle(cornerRadius: isExpanded ? CCTheme.cardRadius : CCTheme.rowRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CCTheme.cardRadius, style: .continuous)
                .strokeBorder(
                    CCTheme.specularBorder(top: 0.32, bottom: 0.08, diagonal: true),
                    lineWidth: 0.8
                )
                .animation(surfaceAnim) {
                    $0.opacity(isExpanded ? 1 : 0)
                }
                .allowsHitTesting(false)
        )
        .geometryGroup()
        .exitFade(visible: !isHidden)
        .frame(height: isHidden ? 0 : (isExpanded ? expandedBodyHeight + 34 : 28), alignment: .top)
        .clipped()
    }
}
