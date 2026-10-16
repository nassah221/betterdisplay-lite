import SwiftUI

struct DisplayModeSubpanel: View {
    @ObservedObject var manager = DisplayManager.shared
    let disp: DisplayInfo

    private var favoriteModes: [DisplayModeItem] {
        let favIDs = Set(manager.favoriteModeIDsByUUID[disp.uuid] ?? [])
        return disp.modes.filter { favIDs.contains($0.id) }
    }
    private var nativeModes: [DisplayModeItem] { disp.modes.filter(\.isNative) }
    private var filteredModes: [DisplayModeItem] {
        let modes = disp.modes.filter { !$0.isNative }
        guard !manager.showAllModesInSubpanel, let native = nativeModes.first else { return modes }
        let natRatio = Double(native.width) / Double(max(native.height, 1))
        return modes.filter { abs(Double($0.width) / Double(max($0.height, 1)) - natRatio) < 0.02 }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 5) {
                // Favorites section + [★ Manage…] button (matching BetterDisplay Image #1)
                HStack(spacing: 4) {
                    Text(favoriteModes.isEmpty ? "No favorites added." : "Favorite modes:")
                        .font(.system(size: 10.5, weight: .regular))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        manager.isManagingFavorites.toggle()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: manager.isManagingFavorites ? "checkmark.circle.fill" : "star.circle")
                                .font(.system(size: 10, weight: .regular))
                            Text(manager.isManagingFavorites ? "Done" : "Manage…")
                                .font(.system(size: 10, weight: .regular))
                        }
                        .foregroundColor(manager.isManagingFavorites ? .white : Color.white.opacity(0.85))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(manager.isManagingFavorites ? Color(red: 0.04, green: 0.52, blue: 1.0) : Color(red: 0.22, green: 0.23, blue: 0.27))
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 36)

                if !favoriteModes.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(favoriteModes) { item in modeRow(item) }
                    }
                }

                Text("Default and native modes:")
                    .font(.system(size: 10.5, weight: .regular))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                ForEach(nativeModes) { item in modeRow(item) }

                HStack(spacing: 4) {
                    Text("Modes matching default filter:").font(.system(size: 10.5, weight: .regular)).foregroundStyle(.secondary)
                    Spacer()
                    Button("Filter: \(manager.showAllModesInSubpanel ? "All" : "Aspect")") {
                        manager.showAllModesInSubpanel.toggle()
                    }
                    .font(.system(size: 10, weight: .regular)).buttonStyle(.plain)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(Capsule().fill(Color(red: 0.22, green: 0.23, blue: 0.27)))
                }
                .padding(.top, 2)
                ForEach(filteredModes) { item in modeRow(item) }
            }
            .padding(.trailing, 10)
        }
        .frame(maxHeight: .infinity)
    }

    private func modeRow(_ item: DisplayModeItem) -> some View {
        let isCurrent = (item.width == disp.currentWidth && item.height == disp.currentHeight && item.isHiDPI == disp.isCurrentHiDPI && item.refreshRate == disp.currentRefreshRate)
        let isFav = manager.isFavoriteMode(item, for: disp)
        return Button {
            if manager.isManagingFavorites {
                manager.toggleFavoriteMode(item, for: disp)
            } else {
                manager.setDisplayMode(item, for: disp)
            }
        } label: {
            HStack(spacing: 5) {
                Group {
                    if manager.isManagingFavorites {
                        Image(systemName: isFav ? "star.circle.fill" : "plus.circle")
                            .foregroundStyle(isFav ? Color.yellow : .secondary)
                    } else if isCurrent {
                        Image(systemName: isFav ? "star.circle.fill" : "checkmark.circle.fill")
                            .foregroundStyle(Color(red: 0.04, green: 0.52, blue: 1.0))
                    } else if isFav {
                        Image(systemName: "star.circle.fill").foregroundStyle(Color.yellow.opacity(0.85))
                    } else if item.isNative {
                        Image(systemName: "star.circle").foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "circle.dotted").foregroundStyle(.secondary)
                    }
                }
                .font(.system(size: 18)).frame(width: 20, height: 20)
                Text("\(item.width) × \(item.height)").font(.system(size: 12, weight: .regular))
                Spacer(minLength: 2)
                if item.isHiDPI { Image(systemName: "sparkles").font(.system(size: 11)).foregroundStyle(.secondary) }
                CCModeBadge(text: item.aspectRatioString)
                CCModeBadge(text: "\(item.refreshRate)Hz")
                CCModeBadge(text: "\(item.bitDepth)-bit")
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ImageAdjustmentsSubpanel: View {
    @ObservedObject var manager = DisplayManager.shared
    let disp: DisplayInfo

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 4) {
                slider("Contrast", "circle.lefthalf.filled", \.contrast, -0.5...0.5, badge: true)
                    .padding(.top, 36)
                slider("Gamma", "sparkles", \.gamma, -0.5...0.5, badge: true)
                slider("Gain", "bolt", \.gain, -0.5...0.5, badge: true)
                Divider().opacity(0.3).padding(.vertical, 1)
                slider("Highlight", "sun.max", \.highlight, -0.5...0.5)
                slider("Shadow", "moon", \.shadow, -0.5...0.5)
                Divider().opacity(0.3).padding(.vertical, 1)
                slider("Color Temperature", "thermometer.sun", \.colorTemperature, -0.5...0.5, badge: true)
                slider("Saturation", "circle.lefthalf.filled", \.saturation, -1.0...1.0)
                slider("Vibrance", "slider.horizontal.3", \.vibrance, -1.0...1.0)
                slider("Hue", "circle.dotted", \.hue, -1.0...1.0)
                slider("Sepia", "photo", \.sepia, 0.0...1.0)
                slider("Quantization", "chart.bar.fill", \.quantization, 4.0...256.0, badge: true, neutral: 256.0)
                Divider().opacity(0.3).padding(.vertical, 1)
                slider("Gamma (Red)", "r.circle", \.gammaRed, -0.5...0.5, badge: true)
                slider("Gamma (Green)", "g.circle", \.gammaGreen, -0.5...0.5, badge: true)
                slider("Gamma (Blue)", "b.circle", \.gammaBlue, -0.5...0.5, badge: true)
                Divider().opacity(0.3).padding(.vertical, 1)
                slider("Gain (Red)", "r.circle", \.gainRed, -0.5...0.5, badge: true)
                slider("Gain (Green)", "g.circle", \.gainGreen, -0.5...0.5, badge: true)
                slider("Gain (Blue)", "b.circle", \.gainBlue, -0.5...0.5, badge: true)

                Divider().opacity(0.4).padding(.vertical, 3)

                CCToggleCircleRow(
                    icon: "paintpalette",
                    title: "Enable Color Table Control",
                    isActive: manager.currentAdjustments.enableColorTable,
                    horizontalPadding: 2
                ) {
                    var a = manager.currentAdjustments
                    a.enableColorTable.toggle()
                    manager.currentAdjustments = a
                }

                Divider().opacity(0.4).padding(.vertical, 3)

                CCToggleCircleRow(
                    icon: "pause.circle",
                    title: "Suspend All Adjustments",
                    isActive: manager.currentAdjustments.suspended,
                    horizontalPadding: 2
                ) {
                    var a = manager.currentAdjustments
                    a.suspended.toggle()
                    manager.currentAdjustments = a
                }

                Button {
                    var a = manager.currentAdjustments
                    a.resetColors()
                    manager.currentAdjustments = a
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.85))
                            .frame(width: 20, height: 20, alignment: .center)
                        Text("Reset All Adjustments")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.92))
                        Spacer()
                    }
                    .padding(.horizontal, 2)
                    .frame(height: 26)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 10)
        }
        .frame(maxHeight: .infinity)
    }

    private func adjustmentBinding(_ keyPath: WritableKeyPath<ImageAdjustments, Double>) -> Binding<Double> {
        Binding(get: { manager.currentAdjustments[keyPath: keyPath] }, set: { value in
            var a = manager.currentAdjustments; a[keyPath: keyPath] = value; manager.currentAdjustments = a
        })
    }

    private func adjustmentBinding(_ keyPath: WritableKeyPath<ImageAdjustments, Bool>) -> Binding<Bool> {
        Binding(get: { manager.currentAdjustments[keyPath: keyPath] }, set: { value in
            var a = manager.currentAdjustments; a[keyPath: keyPath] = value; manager.currentAdjustments = a
        })
    }

    private func slider(_ title: String, _ icon: String, _ keyPath: WritableKeyPath<ImageAdjustments, Double>, _ range: ClosedRange<Double>, badge: Bool = false, neutral: Double = 0) -> some View {
        let v = manager.currentAdjustments[keyPath: keyPath]
        let span = range.upperBound - range.lowerBound
        let labelText = range.upperBound > 10 ? "\(Int(round(v)))" : "\(Int(round((v / max(span * 0.5, 0.5)) * 100)))%"
        return CCSlider(title: title, icon: icon, hasPaletteBadge: badge, value: adjustmentBinding(keyPath), range: range, neutralValue: neutral, rightLabel: labelText, horizontalPadding: 2)
    }
}

struct TextClaritySubpanel: View {
    @ObservedObject var manager = DisplayManager.shared
    let disp: DisplayInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current framebuffer: \(disp.isCurrentHiDPI ? "HiDPI 2×" : "LoDPI 1×")")
                .font(.system(size: 11.5, weight: .regular)).foregroundStyle(.secondary)
                .padding(.top, 38)
            if !disp.isBuiltin {
                Button("Install Flexible HiDPI Override…") { manager.installSystemFlexibleScalingOverride(for: disp) }
                    .font(.system(size: 11, weight: .regular)).buttonStyle(.plain)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.04, green: 0.52, blue: 1.0)))
            }
            Text("macOS Font Smoothing").font(.system(size: 11.5, weight: .regular))
            HStack(spacing: 5) {
                ForEach(Array(["Off", "Light", "Medium", "Heavy"].enumerated()), id: \.offset) { level, title in
                    let active = (manager.fontSmoothingLevel == level)
                    Button(title) { manager.setFontSmoothing(level) }
                        .font(.system(size: 10.5, weight: .regular))
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 6).fill(active ? Color(red: 0.04, green: 0.52, blue: 1.0) : Color(red: 0.20, green: 0.21, blue: 0.25)))
                }
            }
            CCSlider(title: "Monitor Sharpness (DDC)", icon: "viewfinder", value: Binding(get: { manager.currentAdjustments.hardwareSharpness }, set: { manager.setHardwareSharpness($0) }), range: 0.0...1.0, horizontalPadding: 2)
            Spacer(minLength: 0)
        }
    }
}

struct SystemColorsSubpanel: View {
    @ObservedObject var manager = DisplayManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CCToggleCircleRow(icon: "circle.lefthalf.filled", title: "Enable Dark Mode", isActive: manager.isDarkMode, horizontalPadding: 2) { manager.isDarkMode.toggle(); SystemColorsController.shared.isDarkMode = manager.isDarkMode }
                .padding(.top, 38)
            CCToggleCircleRow(icon: "sun.max.fill", title: "Enable True Tone", isActive: manager.isTrueToneEnabled, horizontalPadding: 2) { manager.isTrueToneEnabled.toggle(); SystemColorsController.shared.isTrueToneEnabled = manager.isTrueToneEnabled }
            CCToggleCircleRow(icon: "sun.max", title: "Enable Night Shift", isActive: manager.isNightShiftEnabled, horizontalPadding: 2) { manager.isNightShiftEnabled.toggle(); SystemColorsController.shared.isNightShiftEnabled = manager.isNightShiftEnabled }
            Divider()
            CCSlider(title: "Night Shift Intensity", icon: "sun.max", value: Binding(get: { manager.nightShiftStrength }, set: { manager.nightShiftStrength = $0; SystemColorsController.shared.nightShiftStrength = Float($0) }), range: 0.0...1.0, horizontalPadding: 2)
            Spacer(minLength: 0)
        }
    }
}
