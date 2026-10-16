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

// MARK: - Custom Slider
// NOTE: the SwiftUI State property wrapper / macro plugin is unavailable on this
// toolchain, so these components keep no per-view stored state.

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
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.90))
                if hasPaletteBadge {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.secondary)
                }
                Spacer()
                if let rightLabel {
                    Text(rightLabel)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(Color.white.opacity(0.75))
                }
                if showResetButton && abs(value - neutralValue) > 0.005 {
                    Button {
                        value = neutralValue
                        onEditingChanged?(false)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 9.5, weight: .regular))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help("Reset to neutral")
                }
            }
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.72))
                    .frame(width: 20, height: 18, alignment: .center)

                ZStack {
                    Capsule()
                        .fill(Color.white.opacity(0.18))
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.32), Color.white.opacity(0.08)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.6
                                )
                        )
                        .frame(height: 5)
                        .allowsHitTesting(false)

                    NativeLiquidGlassSlider(
                        value: $value,
                        range: range,
                        onEditingChanged: onEditingChanged
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
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.85))
                    .frame(width: 20, height: 20, alignment: .center)
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.92))
                Spacer()
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 10.5, weight: .regular))
                        .foregroundColor(.secondary)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 9.5, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, horizontalPadding)
            .frame(height: 26)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                    .fill(isActive ? Color(red: 0.04, green: 0.52, blue: 1.0) : Color.white.opacity(0.12))
                    .frame(width: 20, height: 20)
                    .overlay {
                        if let badgeText {
                            Text(badgeText)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        } else if let icon {
                            Image(systemName: icon)
                                .font(.system(size: 10.5, weight: .regular))
                                .foregroundColor(isActive ? .white : .secondary)
                        }
                    }
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.92))
                Spacer()
            }
            .padding(.horizontal, horizontalPadding)
            .frame(height: 26)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sub-panel Header Pill

struct CCSubpanelHeader: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12.5))
                    .frame(width: 20, height: 20, alignment: .center)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Mode Badge Pill

struct CCModeBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 9.5, weight: .regular))
            .foregroundColor(Color.white.opacity(0.75))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.12))
            )
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
        ZStack(alignment: .top) {
            // Bottom Layer: Scrollable/body content spans full card height with top inset for the floating Liquid Glass header sheet
            Color.clear
                .frame(height: isExpanded ? expandedBodyHeight + 34 : 26)
                .overlay(alignment: .top) {
                    bodyContent()
                    .padding(.horizontal, 6)
                    .padding(.bottom, 6)
                    .frame(height: expandedBodyHeight + 34, alignment: .top)
                    .geometryGroup()
                    .opacity(isExpanded ? 1.0 : 0.0)
                }
                .clipped()

            // Top Layer: Floating Liquid Glass header sheet (2pt concentric inset when expanded, matching Image #3!)
            Button(action: onToggle) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.90))
                        .frame(width: 20, height: 20, alignment: .center)
                    Text(title)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.95))
                    Spacer()
                    if let subtitle, !isExpanded {
                        Text(subtitle)
                            .font(.system(size: 10.5, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9.5, weight: .regular))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, isExpanded ? 6 : 8)
                .frame(height: isExpanded ? 30 : 26)
                .frame(maxWidth: .infinity)
                .background {
                    if isExpanded {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.06))
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(isExpanded ? 2 : 0)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isExpanded ? Color(red: 0.12, green: 0.13, blue: 0.16) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: isExpanded ? [Color.white.opacity(0.28), Color.white.opacity(0.10)] : [Color.clear, Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .geometryGroup()
        .frame(height: isHidden ? 0 : (isExpanded ? expandedBodyHeight + 34 : 26), alignment: .top)
        .clipped()
    }
}
