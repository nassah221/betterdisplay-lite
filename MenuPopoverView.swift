import AppKit
import SwiftUI

enum PopoverLayoutMetrics {
    static let width: CGFloat = 292

    static var screenHeight: CGFloat {
        NSScreen.main?.visibleFrame.height ?? 1050.0
    }

    static func expandedBodyHeight(for sub: DisplayManager.ActiveSubmenu) -> CGFloat {
        switch sub {
        case .imageAdjustments:
            return min(max(round(screenHeight * 0.42), 310), 460)
        case .displayMode:
            return min(max(round(screenHeight * 0.32), 230), 340)
        case .textClarity:
            return 146
        case .systemColors:
            return 152
        case .none, .screenRotation:
            return 0
        }
    }

    static func middleHeight(for sub: DisplayManager.ActiveSubmenu) -> CGFloat {
        switch sub {
        case .none, .screenRotation:
            return 222
        case .systemColors:
            return 0
        case .displayMode, .imageAdjustments, .textClarity:
            return expandedBodyHeight(for: sub) + 34
        }
    }

    static func totalHeight(for manager: DisplayManager) -> CGFloat {
        let dispRows = CGFloat(max(manager.displays.count, 1))
        let headerH = dispRows * 27.0 + (dispRows > 1 ? (dispRows - 1) * 3.0 : 0) + 6.0
        let sub = manager.activeSubmenu
        let isMiddleExpanded = (sub == .displayMode || sub == .imageAdjustments || sub == .textClarity)
        let toolsH: CGFloat
        if sub == .systemColors {
            toolsH = 28.0 + 2.0 + expandedBodyHeight(for: .systemColors) + 34.0
        } else if isMiddleExpanded {
            toolsH = 28.0
        } else {
            toolsH = 28.0 + 2.0 + 4.0 * 26.0 + 3.0
        }
        let gaps: CGFloat = sub == .systemColors ? 5.0 : 10.0
        return headerH + middleHeight(for: sub) + toolsH + gaps + 10.0
    }
}

struct MenuPopoverView: View {
    @ObservedObject var manager = DisplayManager.shared

    private func expandedBodyHeight(for sub: DisplayManager.ActiveSubmenu) -> CGFloat {
        PopoverLayoutMetrics.expandedBodyHeight(for: sub)
    }

    private var targetMiddleHeight: CGFloat {
        PopoverLayoutMetrics.middleHeight(for: manager.activeSubmenu)
    }

    private var targetPopoverHeight: CGFloat {
        PopoverLayoutMetrics.totalHeight(for: manager)
    }

    var body: some View {
        let h = targetPopoverHeight
        VStack(spacing: 5) {
            displayHeaderCard

            if let disp = manager.selectedDisplay, manager.activeSubmenu != .systemColors {
                middleContent(for: disp)
            }

            toolsSection
        }
        .padding(5)
        .frame(width: PopoverLayoutMetrics.width, height: h, alignment: .top)
        .background(Color(red: 0.11, green: 0.12, blue: 0.15))
        .onAppear {
            manager.refreshDisplays()
            AppDelegate.shared?.updatePopoverSize(width: PopoverLayoutMetrics.width, height: targetPopoverHeight)
        }
        .onChange(of: manager.activeSubmenu) { _, _ in
            AppDelegate.shared?.updatePopoverSize(width: PopoverLayoutMetrics.width, height: targetPopoverHeight)
        }
        .onChange(of: manager.displays.count) { _, _ in
            AppDelegate.shared?.updatePopoverSize(width: PopoverLayoutMetrics.width, height: targetPopoverHeight)
        }
    }

    private var displayHeaderCard: some View {
        VStack(spacing: 3) {
            ForEach(manager.displays) { disp in
                let isSelected = disp.uuid == manager.selectedDisplay?.uuid
                HStack(spacing: 8) {
                    Image(systemName: disp.isBuiltin ? "laptopcomputer" : "display")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                        .frame(width: 20, height: 20, alignment: .center)

                    Text(disp.name)
                        .font(.system(size: 12, weight: .regular))
                        .lineLimit(1)

                    if disp.isMain {
                        Text("M")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(Color.white.opacity(0.14)))
                    }

                    Spacer(minLength: 0)

                    Text("\(disp.currentWidth)×\(disp.currentHeight)\(disp.isCurrentHiDPI ? " ✨" : "")")
                        .font(.system(size: 10.5, weight: .regular, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 8).fill(isSelected ? Color.accentColor.opacity(0.16) : .clear))
                .contentShape(Rectangle())
                .onTapGesture {
                    manager.selectedDisplayUUID = disp.uuid
                    manager.draggingSliderIndex = nil
                }
            }
        }
        .padding(3)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.26), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
    }

    private static let slideSpring = Animation.easeOut(duration: 0.22)

    private func toggleSubmenu(_ target: DisplayManager.ActiveSubmenu) {
        withAnimation(Self.slideSpring) {
            manager.activeSubmenu = (manager.activeSubmenu == target) ? .none : target
        }
    }

    private func middleContent(for disp: DisplayInfo) -> some View {
        let adj = manager.currentAdjustments
        let sub = manager.activeSubmenu
        let isMainIdle = (sub == .none)
        return VStack(alignment: .leading, spacing: 0) {
            // 1. Sliders block: collapses upward via pure height clipping (no opacity transition = no Liquid Glass glow!)
            VStack(alignment: .leading, spacing: 8) {
                CCSlider(
                    title: "Brightness (Combined)",
                    icon: "sun.max.fill",
                    value: Binding(
                        get: { manager.currentAdjustments.combinedBrightness },
                        set: { manager.setCombinedBrightness($0) }
                    ),
                    range: 0.05...1.0,
                    rightLabel: "\(Int(round(adj.combinedBrightness * 100)))%",
                    showResetButton: false
                )

                if !disp.sliderModes.isEmpty {
                    let currentIdx = disp.sliderModes.firstIndex(where: {
                        $0.width == disp.currentWidth && $0.height == disp.currentHeight && $0.isHiDPI == disp.isCurrentHiDPI
                    }) ?? disp.sliderModes.firstIndex(where: {
                        $0.width == disp.currentWidth && $0.height == disp.currentHeight
                    }) ?? (disp.sliderModes.count - 1)
                    let previewIdx = max(0, min(disp.sliderModes.count - 1, Int(round(manager.draggingSliderIndex ?? Double(currentIdx)))))
                    let previewMode = disp.sliderModes[previewIdx]
                    let previewPct = Int(round(Double(previewMode.width) / Double(max(disp.nativeWidth, 1)) * 100))

                    CCSlider(
                        title: "Resolution",
                        icon: "arrow.up.left.and.arrow.down.right",
                        value: Binding(
                            get: { manager.draggingSliderIndex ?? Double(currentIdx) },
                            set: { manager.draggingSliderIndex = $0 }
                        ),
                        range: 0...Double(max(1, disp.sliderModes.count - 1)),
                        rightLabel: "\(previewMode.width) × \(previewMode.height) · \(previewPct)%",
                        showResetButton: false,
                        onEditingChanged: { editing in
                            if !editing, let finalValue = manager.draggingSliderIndex {
                                let targetIdx = max(0, min(disp.sliderModes.count - 1, Int(round(finalValue))))
                                manager.draggingSliderIndex = nil
                                let targetMode = disp.sliderModes[targetIdx]
                                if targetMode.width != disp.currentWidth || targetMode.height != disp.currentHeight || targetMode.isHiDPI != disp.isCurrentHiDPI {
                                    manager.setDisplayMode(targetMode, for: disp)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.top, 2)
            .padding(.bottom, 6)
            .fixedSize(horizontal: false, vertical: true)
            .geometryGroup()
            .opacity(isMainIdle ? 1.0 : 0.0)
            .frame(height: isMainIdle ? nil : 0, alignment: .top)
            .clipped()

            // 2. Expandable sections: header slides UP to top while body fades in & unrolls DOWNWARD without morphing
            CCExpandableSection(
                icon: "rectangle.stack",
                title: "Display Mode",
                isExpanded: sub == .displayMode,
                isHidden: !isMainIdle && sub != .displayMode,
                expandedBodyHeight: expandedBodyHeight(for: .displayMode),
                onToggle: { toggleSubmenu(.displayMode) }
            ) {
                DisplayModeSubpanel(disp: disp)
            }

            CCExpandableSection(
                icon: "slider.horizontal.below.square.and.square.filled",
                title: "Image Adjustments",
                subtitle: !adj.isLUTNeutral || adj.needsCompositorOverlay ? "Active" : nil,
                isExpanded: sub == .imageAdjustments,
                isHidden: !isMainIdle && sub != .imageAdjustments,
                expandedBodyHeight: expandedBodyHeight(for: .imageAdjustments),
                onToggle: { toggleSubmenu(.imageAdjustments) }
            ) {
                ImageAdjustmentsSubpanel(disp: disp)
            }

            CCExpandableSection(
                icon: "textformat.alt",
                title: "Flexible Scaling & Text Clarity",
                subtitle: disp.isCurrentHiDPI ? "HiDPI" : "LoDPI",
                isExpanded: sub == .textClarity,
                isHidden: !isMainIdle && sub != .textClarity,
                expandedBodyHeight: expandedBodyHeight(for: .textClarity),
                onToggle: { toggleSubmenu(.textClarity) }
            ) {
                TextClaritySubpanel(disp: disp)
            }

            // 3. Circle-badge toggles: fixed vertical layout inside outer clip frame so they never squish
            VStack(alignment: .leading, spacing: 1) {
                CCToggleCircleRow(icon: "sparkles", title: "High Resolution (HiDPI)", isActive: disp.isCurrentHiDPI) {
                    manager.toggleHiDPIForCurrentResolution()
                }
                CCToggleCircleRow(title: "Set as Main Display", isActive: disp.isMain, badgeText: "M") {
                    manager.setAsMainDisplay(disp)
                }
            }
            .padding(.top, 2)
            .fixedSize(horizontal: false, vertical: true)
            .geometryGroup()
            .opacity(isMainIdle ? 1.0 : 0.0)
            .frame(height: isMainIdle ? nil : 0, alignment: .top)
            .clipped()
        }
        .frame(height: targetMiddleHeight, alignment: .top)
        .clipped()
    }

    private var toolsSection: some View {
        let sub = manager.activeSubmenu
        let isSysColors = (sub == .systemColors)
        let isMiddleExpanded = (sub == .displayMode || sub == .imageAdjustments || sub == .textClarity)
        return VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 8) {
                Button {
                    if sub != .none {
                        withAnimation(Self.slideSpring) {
                            manager.activeSubmenu = .none
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 0.22, green: 0.23, blue: 0.27))
                            .frame(width: 20, height: 20)
                            .overlay(Image(systemName: "ellipsis").font(.system(size: 9, weight: .regular)))
                        Text("Tools")
                            .font(.system(size: 12, weight: .regular))
                        Spacer(minLength: 4)
                        if !manager.statusMessage.isEmpty {
                            Text(manager.statusMessage)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    manager.refreshDisplays()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .help("Refresh Displays")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.15, green: 0.16, blue: 0.19)))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.24), Color.white.opacity(0.07)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )

            CCExpandableSection(
                icon: "circle.lefthalf.filled",
                title: "System Colors",
                isExpanded: isSysColors,
                isHidden: isMiddleExpanded,
                expandedBodyHeight: expandedBodyHeight(for: .systemColors),
                onToggle: { toggleSubmenu(.systemColors) }
            ) {
                SystemColorsSubpanel()
            }

            VStack(alignment: .leading, spacing: 1) {
                CCMenuRow(
                    icon: manager.launchAtLogin ? "checkmark.circle.fill" : "circle",
                    title: "Launch at Login",
                    subtitle: manager.launchAtLogin ? "On" : "Off"
                ) {
                    manager.setLaunchAtLogin(!manager.launchAtLogin)
                }
                CCMenuRow(icon: "arrow.counterclockwise", title: "Reset All Adjustments", subtitle: "⌘⌥⇧R") {
                    manager.resetAllDisplays()
                }
                CCMenuRow(icon: "xmark.rectangle", title: "Quit DisplayControl") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .geometryGroup()
            .opacity((isSysColors || isMiddleExpanded) ? 0.0 : 1.0)
            .frame(height: (isSysColors || isMiddleExpanded) ? 0 : nil, alignment: .top)
            .clipped()
        }
    }
}
