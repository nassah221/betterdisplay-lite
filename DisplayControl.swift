import AppKit
import Combine
import CoreGraphics
import Foundation
import IOKit
import QuartzCore
import SwiftUI

// MARK: - Private & Public Framework Bridges

@_silgen_name("SLSMainConnectionID")
func SLSMainConnectionID() -> UInt32

@_silgen_name("SLSGetAppearanceThemeLegacy")
func SLSGetAppearanceThemeLegacy() -> Bool

@_silgen_name("SLSSetAppearanceThemeLegacy")
func SLSSetAppearanceThemeLegacy(_ dark: Bool)

@_silgen_name("CGSConfigureDisplayEnabled")
func CGSConfigureDisplayEnabled(_ config: CGDisplayConfigRef, _ display: CGDirectDisplayID, _ enabled: Bool) -> CGError

@_silgen_name("CGSSetDisplayContrast")
func CGSSetDisplayContrast(_ contrast: Float) -> CGError

@_silgen_name("DisplayServicesGetBrightness")
func DisplayServicesGetBrightness(_ display: CGDirectDisplayID, _ brightness: UnsafeMutablePointer<Float>) -> Int32

@_silgen_name("DisplayServicesSetBrightness")
func DisplayServicesSetBrightness(_ display: CGDirectDisplayID, _ brightness: Float) -> Int32

@_silgen_name("CoreDisplay_DisplayCreateInfoDictionary")
func CoreDisplay_DisplayCreateInfoDictionary(_ display: CGDirectDisplayID) -> Unmanaged<CFDictionary>?

@_silgen_name("CGDisplayCreateUUIDFromDisplayID")
func CGDisplayCreateUUIDFromDisplayID(_ display: CGDirectDisplayID) -> Unmanaged<CFUUID>?

@_silgen_name("IOAVServiceCreateWithService")
func IOAVServiceCreateWithService(_ allocator: CFAllocator?, _ service: io_service_t) -> Unmanaged<CFTypeRef>?

@_silgen_name("IOAVServiceReadI2C")
func IOAVServiceReadI2C(_ service: CFTypeRef, _ chipAddress: UInt32, _ offset: UInt32, _ outputBuffer: UnsafeMutableRawPointer, _ outputBufferSize: UInt32) -> IOReturn

@_silgen_name("IOAVServiceWriteI2C")
func IOAVServiceWriteI2C(_ service: CFTypeRef, _ chipAddress: UInt32, _ dataAddress: UInt32, _ inputBuffer: UnsafeMutableRawPointer, _ inputBufferSize: UInt32) -> IOReturn

struct CGSDisplayModeDescription {
    var displayModeNumber: UInt32 = 0
    var flags: UInt32 = 0
    var width: UInt32 = 0
    var height: UInt32 = 0
    var depth: UInt32 = 0
    var rowBytes: UInt32 = 0
    var bitsPerPixel: UInt32 = 0
    var bitsPerSample: UInt32 = 0
    var samplesPerPixel: UInt32 = 0
    var refreshRate: UInt32 = 0
    var horizontalResolution: UInt32 = 0
    var verticalResolution: UInt32 = 0
    var encoding: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    var version: UInt16 = 0
    var length: UInt16 = 0
    var fixPtRefreshRate: UInt32 = 0
    var ioModeInfoFlags: UInt32 = 0
    var ioDisplayModeNumber: UInt32 = 0
    var pixelsWide: UInt32 = 0
    var pixelsHigh: UInt32 = 0
    var resolution: Float = 0
}

@_silgen_name("CGSGetNumberOfDisplayModes")
func CGSGetNumberOfDisplayModes(_ display: CGDirectDisplayID, _ nModes: UnsafeMutablePointer<Int32>) -> CGError

@_silgen_name("CGSGetDisplayModeDescriptionOfLength")
func CGSGetDisplayModeDescriptionOfLength(_ display: CGDirectDisplayID, _ idx: Int32, _ desc: UnsafeMutablePointer<CGSDisplayModeDescription>, _ length: Int32) -> CGError
// MARK: - Data Models

struct DisplayModeItem: Identifiable, Hashable {
    let id: String
    let modeRef: CGDisplayMode
    let ioModeID: Int32
    let width: Int
    let height: Int
    let pixelWidth: Int
    let pixelHeight: Int
    let refreshRate: Int
    let bitDepth: Int
    let isHiDPI: Bool
    let isNative: Bool

    var aspectRatioString: String {
        let g = Self.gcd(width, height)
        guard g > 0 else { return "" }
        let rw = width / g
        let rh = height / g
        let ratio = Double(width) / Double(max(height, 1))
        if abs(ratio - 16.0 / 9.0) < 0.02 { return "16:9" }
        if abs(ratio - 16.0 / 10.0) < 0.02 { return "16:10" }
        if abs(ratio - 2880.0 / 1864.0) < 0.02 { return "Notch" }
        return "\(rw):\(rh)"
    }

    static func gcd(_ a: Int, _ b: Int) -> Int {
        var x = a, y = b
        while y != 0 {
            let t = y
            y = x % y
            x = t
        }
        return x
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DisplayModeItem, rhs: DisplayModeItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct ImageAdjustments: Codable, Equatable {
    // Combined / Software Brightness (0.0 .. 1.0, default 1.0)
    var combinedBrightness: Double = 1.0
    var volume: Double = 0.75
    var hardwareSharpness: Double = 0.50

    // Color Table (LUT) Adjustments (-0.5 .. +0.5, default 0.0)
    var contrast: Double = 0.0
    var gamma: Double = 0.0
    var gain: Double = 0.0
    var highlight: Double = 0.0
    var shadow: Double = 0.0
    var colorTemperature: Double = 0.0 // -0.5 (cool) .. +0.5 (warm)
    var quantization: Double = 256.0   // 4 .. 256

    // Per-Channel RGB Color Table (-0.5 .. +0.5)
    var gammaRed: Double = 0.0
    var gammaGreen: Double = 0.0
    var gammaBlue: Double = 0.0
    var gainRed: Double = 0.0
    var gainGreen: Double = 0.0
    var gainBlue: Double = 0.0

    // Compositor Filter Adjustments
    var saturation: Double = 0.0  // -1.0 .. +1.0 (0 = neutral)
    var vibrance: Double = 0.0    // -1.0 .. +1.0
    var hue: Double = 0.0         // -1.0 .. +1.0 (-180° .. +180°)
    var sepia: Double = 0.0       // 0.0 .. 1.0

    // Method toggles (matching BetterDisplay Image #2)
    var enableColorTable: Bool = true
    var enableCompositorFilter: Bool = true
    var hideOverlayInScreenshots: Bool = true
    var suspended: Bool = false

    var isLUTNeutral: Bool {
        abs(combinedBrightness - 1.0) < 0.005 &&
        abs(contrast) < 0.005 &&
        abs(gamma) < 0.005 &&
        abs(gain) < 0.005 &&
        abs(highlight) < 0.005 &&
        abs(shadow) < 0.005 &&
        abs(colorTemperature) < 0.005 &&
        quantization >= 255.0 &&
        abs(gammaRed) < 0.005 &&
        abs(gammaGreen) < 0.005 &&
        abs(gammaBlue) < 0.005 &&
        abs(gainRed) < 0.005 &&
        abs(gainGreen) < 0.005 &&
        abs(gainBlue) < 0.005
    }

    var needsCompositorOverlay: Bool {
        guard enableCompositorFilter && !suspended else { return false }
        return abs(saturation) > 0.005 ||
               abs(vibrance) > 0.005 ||
               abs(hue) > 0.005 ||
               sepia > 0.005
    }

    mutating func resetColors() {
        contrast = 0.0
        gamma = 0.0
        gain = 0.0
        highlight = 0.0
        shadow = 0.0
        colorTemperature = 0.0
        quantization = 256.0
        gammaRed = 0.0
        gammaGreen = 0.0
        gammaBlue = 0.0
        gainRed = 0.0
        gainGreen = 0.0
        gainBlue = 0.0
        saturation = 0.0
        vibrance = 0.0
        hue = 0.0
        sepia = 0.0
        suspended = false
    }
}

struct DisplayInfo: Identifiable {
    let id: CGDirectDisplayID
    let uuid: String
    let name: String
    let vendorID: Int
    let productID: Int
    let isBuiltin: Bool
    let isVirtual: Bool
    let isMain: Bool
    let isEnabled: Bool
    let currentWidth: Int
    let currentHeight: Int
    let currentPixelWidth: Int
    let currentPixelHeight: Int
    let currentRefreshRate: Int
    let bitDepth: Int
    let isCurrentHiDPI: Bool
    let nativeWidth: Int
    let nativeHeight: Int
    let modes: [DisplayModeItem]
    let sliderModes: [DisplayModeItem]

    var resolutionPercentage: Int {
        let baseW = Double(max(nativeWidth, 1))
        return Int(round((Double(currentWidth) / baseW) * 100.0))
    }

    var overridePlistPath: String {
        String(format: "/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-%x/DisplayProductID-%x", vendorID, productID)
    }

    var hasSystemOverrideInstalled: Bool {
        FileManager.default.fileExists(atPath: overridePlistPath)
    }
}

// MARK: - DDC/CI Hardware Controller (Apple Silicon IOAVService)

final class DDCController {
    static let shared = DDCController()
    private let queue = DispatchQueue(label: "com.displaycontrol.ddc", qos: .userInitiated)
    private var lastWriteTime: [String: TimeInterval] = [:]

    enum VCP: UInt8 {
        case brightness = 0x10
        case contrast   = 0x12
        case redGain    = 0x16
        case greenGain  = 0x18
        case blueGain   = 0x1A
        case volume     = 0x62
        case sharpness  = 0x87
    }

    private func findExternalAVService() -> CFTypeRef? {
        var iter = io_iterator_t()
        guard IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("DCPAVServiceProxy"), &iter) == KERN_SUCCESS else {
            return nil
        }
        defer { IOObjectRelease(iter) }
        while case let service = IOIteratorNext(iter), service != IO_OBJECT_NULL {
            defer { IOObjectRelease(service) }
            if let loc = IORegistryEntryCreateCFProperty(service, "Location" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String,
               loc == "External",
               let av = IOAVServiceCreateWithService(kCFAllocatorDefault, service)?.takeRetainedValue() {
                return av
            }
        }
        return nil
    }

    func write(vcp: VCP, value: UInt16, throttleKey: String? = nil) {
        let key = throttleKey ?? "\(vcp.rawValue)"
        let now = CFAbsoluteTimeGetCurrent()
        // ponytail: 30ms throttle per VCP code prevents I2C bus saturation while dragging sliders
        if let last = lastWriteTime[key], now - last < 0.030 {
            return
        }
        lastWriteTime[key] = now

        queue.async { [weak self] in
            guard let av = self?.findExternalAVService() else { return }
            let hi = UInt8((value >> 8) & 0xFF)
            let lo = UInt8(value & 0xFF)
            let chk: UInt8 = 0x6E ^ 0x51 ^ 0x84 ^ 0x03 ^ vcp.rawValue ^ hi ^ lo
            var packet: [UInt8] = [0x84, 0x03, vcp.rawValue, hi, lo, chk]
            for _ in 0..<2 {
                usleep(10_000)
                _ = IOAVServiceWriteI2C(av, 0x37, 0x51, &packet, UInt32(packet.count))
            }
        }
    }
}

// MARK: - CoreBrightness Bridge (Night Shift & True Tone)

final class SystemColorsController {
    static let shared = SystemColorsController()

    private var blueLightClient: NSObject?
    private var adaptationClient: NSObject?

    private struct BlueLightSchedule {
        var fromHour: Int32 = 0
        var fromMinute: Int32 = 0
        var toHour: Int32 = 0
        var toMinute: Int32 = 0
    }

    private struct BlueLightStatus {
        var active: Bool = false
        var enabled: Bool = false
        var sunSchedulePermitted: Bool = false
        var mode: Int32 = 0
        var schedule: BlueLightSchedule = BlueLightSchedule()
        var disableFlags: UInt64 = 0
        var available: Bool = false
    }

    init() {
        if let bundle = Bundle(path: "/System/Library/PrivateFrameworks/CoreBrightness.framework"), bundle.load() {
            if let blCls = NSClassFromString("CBBlueLightClient") as? NSObject.Type {
                blueLightClient = blCls.init()
            }
            if let ttCls = NSClassFromString("CBAdaptationClient") as? NSObject.Type {
                adaptationClient = ttCls.init()
            }
        }
    }

    var isDarkMode: Bool {
        get { SLSGetAppearanceThemeLegacy() }
        set { SLSSetAppearanceThemeLegacy(newValue) }
    }

    var isTrueToneAvailable: Bool {
        guard let client = adaptationClient else { return false }
        let sel = NSSelectorFromString("available")
        guard client.responds(to: sel) else { return false }
        typealias Fn = @convention(c) (AnyObject, Selector) -> Bool
        let imp = client.method(for: sel)
        return unsafeBitCast(imp, to: Fn.self)(client, sel)
    }

    var isTrueToneEnabled: Bool {
        get {
            guard let client = adaptationClient else { return false }
            let sel = NSSelectorFromString("getEnabled")
            guard client.responds(to: sel) else { return false }
            typealias Fn = @convention(c) (AnyObject, Selector) -> Bool
            let imp = client.method(for: sel)
            return unsafeBitCast(imp, to: Fn.self)(client, sel)
        }
        set {
            guard let client = adaptationClient else { return }
            let sel = NSSelectorFromString("setEnabled:")
            guard client.responds(to: sel) else { return }
            typealias Fn = @convention(c) (AnyObject, Selector, Bool) -> Bool
            let imp = client.method(for: sel)
            _ = unsafeBitCast(imp, to: Fn.self)(client, sel, newValue)
        }
    }

    var isNightShiftEnabled: Bool {
        get {
            guard let client = blueLightClient else { return false }
            let sel = NSSelectorFromString("getBlueLightStatus:")
            guard client.responds(to: sel) else { return false }
            typealias Fn = @convention(c) (AnyObject, Selector, UnsafeMutableRawPointer) -> Bool
            let imp = client.method(for: sel)
            var status = BlueLightStatus()
            _ = withUnsafeMutablePointer(to: &status) { ptr in
                unsafeBitCast(imp, to: Fn.self)(client, sel, UnsafeMutableRawPointer(ptr))
            }
            return status.enabled
        }
        set {
            guard let client = blueLightClient else { return }
            let sel = NSSelectorFromString("setEnabled:")
            guard client.responds(to: sel) else { return }
            typealias Fn = @convention(c) (AnyObject, Selector, Bool) -> Bool
            let imp = client.method(for: sel)
            _ = unsafeBitCast(imp, to: Fn.self)(client, sel, newValue)
        }
    }

    var nightShiftStrength: Float {
        get {
            guard let client = blueLightClient else { return 0.5 }
            let sel = NSSelectorFromString("getStrength:")
            guard client.responds(to: sel) else { return 0.5 }
            typealias Fn = @convention(c) (AnyObject, Selector, UnsafeMutablePointer<Float>) -> Bool
            let imp = client.method(for: sel)
            var val: Float = 0.5
            _ = unsafeBitCast(imp, to: Fn.self)(client, sel, &val)
            return val
        }
        set {
            guard let client = blueLightClient else { return }
            let sel = NSSelectorFromString("setStrength:commit:")
            guard client.responds(to: sel) else { return }
            typealias Fn = @convention(c) (AnyObject, Selector, Float, Bool) -> Bool
            let imp = client.method(for: sel)
            if newValue > 0.01 && !isNightShiftEnabled {
                isNightShiftEnabled = true
            }
            _ = unsafeBitCast(imp, to: Fn.self)(client, sel, max(0.0, min(1.0, newValue)), true)
        }
    }
}

// MARK: - Compositor Overlay Controller (CABackdropLayer + CAFilter)

final class CompositorOverlayManager {
    static let shared = CompositorOverlayManager()
    private var windows: [CGDirectDisplayID: NSWindow] = [:]

    func updateOverlay(for displayID: CGDirectDisplayID, adjustments: ImageAdjustments) {
        guard adjustments.needsCompositorOverlay,
              let screen = NSScreen.screens.first(where: {
                  ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID) == displayID
              }) else {
            removeOverlay(for: displayID)
            return
        }

        let win: NSWindow
        if let existing = windows[displayID] {
            win = existing
            win.setFrame(screen.frame, display: true)
        } else {
            let w = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            w.isOpaque = false
            w.backgroundColor = .clear
            w.ignoresMouseEvents = true
            w.hasShadow = false
            w.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
            w.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]

            if let backdropCls = NSClassFromString("CABackdropLayer") as? CALayer.Type {
                let view = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
                view.wantsLayer = true
                let layer = backdropCls.init()
                layer.frame = view.bounds
                layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
                layer.setValue(true, forKey: "enabled")
                layer.setValue("DisplayControlBackdrop-\(displayID)", forKey: "groupName")
                view.layer = layer
                w.contentView = view
            }
            w.orderFrontRegardless()
            windows[displayID] = w
            win = w
        }

        win.sharingType = adjustments.hideOverlayInScreenshots ? .none : .readOnly

        guard let layer = win.contentView?.layer,
              let filterCls = NSClassFromString("CAFilter") as? NSObject.Type else { return }

        let createSel = NSSelectorFromString("filterWithType:")
        typealias CreateFn = @convention(c) (AnyObject, Selector, CFString) -> AnyObject?
        let imp = (filterCls as AnyObject).method(for: createSel)
        let makeFilter = unsafeBitCast(imp, to: CreateFn.self)

        var filters: [AnyObject] = []

        let satTotal = max(0.0, min(3.0, 1.0 + adjustments.saturation + adjustments.vibrance * 0.65))
        if abs(satTotal - 1.0) > 0.005, let f = makeFilter(filterCls, createSel, "colorSaturate" as CFString) {
            f.setValue(NSNumber(value: satTotal), forKey: "inputAmount")
            filters.append(f)
        }

        if abs(adjustments.hue) > 0.005, let f = makeFilter(filterCls, createSel, "colorHueRotate" as CFString) {
            f.setValue(NSNumber(value: adjustments.hue * Double.pi), forKey: "inputAngle")
            filters.append(f)
        }

        if adjustments.sepia > 0.005, let f = makeFilter(filterCls, createSel, "colorMonochrome" as CFString) {
            f.setValue(NSNumber(value: adjustments.sepia), forKey: "inputAmount")
            let sepiaColor = CGColor(red: 0.44, green: 0.26, blue: 0.08, alpha: 1.0)
            f.setValue(sepiaColor, forKey: "inputColor")
            filters.append(f)
        }

        layer.filters = filters
    }

    func removeOverlay(for displayID: CGDirectDisplayID) {
        if let win = windows.removeValue(forKey: displayID) {
            win.orderOut(nil)
        }
    }

    func removeAll() {
        for (_, win) in windows {
            win.orderOut(nil)
        }
        windows.removeAll()
    }
}

// MARK: - Main ViewModel & Display State Manager

final class DisplayManager: ObservableObject {
    static let shared = DisplayManager()

    @Published var displays: [DisplayInfo] = []
    @Published var selectedDisplayUUID: String = ""
    @Published var adjustmentsByUUID: [String: ImageAdjustments] = [:]
    @Published var adjustmentTab: AdjustmentTab = .toneAndTemp
    @Published var statusMessage: String = ""

    // System Colors state
    @Published var isDarkMode: Bool = SLSGetAppearanceThemeLegacy()
    @Published var isTrueToneEnabled: Bool = SystemColorsController.shared.isTrueToneEnabled
    @Published var isNightShiftEnabled: Bool = SystemColorsController.shared.isNightShiftEnabled
    @Published var nightShiftStrength: Double = Double(SystemColorsController.shared.nightShiftStrength)

    // Text Clarity / Font Smoothing state (0=Off, 1=Light, 2=Medium, 3=Heavy)
    @Published var fontSmoothingLevel: Int = 2
    @Published var draggingSliderIndex: Double? = nil
    @Published var activeSubmenu: ActiveSubmenu = .none
    @Published var showAllModesInSubpanel: Bool = false
    @Published var launchAtLogin: Bool = false
    @Published var favoriteModeIDsByUUID: [String: [String]] = [:]
    @Published var isManagingFavorites: Bool = false

    enum ActiveSubmenu: Equatable {
        case none
        case displayMode
        case imageAdjustments
        case textClarity
        case screenRotation
        case systemColors
    }

    enum AdjustmentTab: String, CaseIterable {
        case toneAndTemp = "Tone & Temp"
        case rgbChannels = "RGB Channels"
        case colorAndEffects = "Color & Effects"
    }

    private let defaultsKey = "DisplayControl.AdjustmentsByUUID.v1"
    private let favoritesKey = "DisplayControl.FavoriteModesByUUID.v1"
    private var lutEnforcementTimer: Timer?
    private var disabledDisplaysByUUID: [String: DisplayInfo] = [:]

    private init() {
        loadSavedAdjustments()
        loadFavorites()
        loadFontSmoothing()
        refreshDisplays()
        loadLaunchAtLogin()
        applyAllAdjustments()

        // Re-apply LUT & refresh displays on wake or display hotplug
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self?.refreshDisplays()
                self?.applyAllAdjustments()
            }
        }

        // Periodic lightweight LUT drift check (re-asserts LUT if ColorSync / Night Shift overwrote it)
        lutEnforcementTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.enforceLUTIfDrifted()
        }
    }

    var selectedDisplay: DisplayInfo? {
        displays.first(where: { $0.uuid == selectedDisplayUUID }) ?? displays.first
    }

    var currentAdjustments: ImageAdjustments {
        get {
            guard let uuid = selectedDisplay?.uuid else { return ImageAdjustments() }
            return adjustmentsByUUID[uuid] ?? ImageAdjustments()
        }
        set {
            guard let disp = selectedDisplay else { return }
            adjustmentsByUUID[disp.uuid] = newValue
            saveAdjustments()
            applyAdjustments(for: disp, adjustments: newValue)
        }
    }

    // MARK: - Display Enumeration

    func refreshDisplays() {
        var onlineIDs = [CGDirectDisplayID](repeating: 0, count: 16)
        var onlineCount: UInt32 = 0
        CGGetOnlineDisplayList(16, &onlineIDs, &onlineCount)

        var activeIDs = [CGDirectDisplayID](repeating: 0, count: 16)
        var activeCount: UInt32 = 0
        CGGetActiveDisplayList(16, &activeIDs, &activeCount)
        let activeSet = Set(activeIDs.prefix(Int(activeCount)))

        var built: [DisplayInfo] = []
        for i in 0..<Int(onlineCount) {
            let did = onlineIDs[i]
            let uuid = Self.displayUUID(for: did)
            let isBuiltin = CGDisplayIsBuiltin(did) != 0
            let isMain = CGDisplayIsMain(did) != 0
            let isEnabled = activeSet.contains(did)
            let vendorID = Int(CGDisplayVendorNumber(did))
            let productID = Int(CGDisplayModelNumber(did))

            var name = isBuiltin ? "Built-in Display" : "External Display"
            var isVirtual = false
            if let cfDict = CoreDisplay_DisplayCreateInfoDictionary(did)?.takeRetainedValue() as NSDictionary? {
                if let pname = cfDict["DisplayProductName"] as? [String: String],
                   let enName = pname["en_US"] ?? pname.values.first {
                    name = isBuiltin ? "Built-in Display (\(enName))" : enName
                }
                if let virt = cfDict["kCGDisplayIsVirtualDevice"] as? Bool, virt {
                    isVirtual = true
                }
            }
            if isVirtual { continue }

            let curMode = CGDisplayCopyDisplayMode(did)
            let curW = curMode?.width ?? CGDisplayPixelsWide(did)
            let curH = curMode?.height ?? CGDisplayPixelsHigh(did)
            let curPW = curMode?.pixelWidth ?? curW
            let curPH = curMode?.pixelHeight ?? curH
            let curHz = Int(round(curMode?.refreshRate ?? 60.0))
            let isCurHiDPI = curPW > curW

            let hwBpc = Self.hardwareBitDepth(for: did, vendorID: vendorID, productID: productID, isBuiltin: isBuiltin)
            let allModes = Self.enumerateModes(for: did, defaultBitDepth: hwBpc)
            let nativeMode = allModes.first(where: { $0.isNative })
            let natW = nativeMode?.width ?? (isBuiltin ? 1710 : 2560)
            let natH = nativeMode?.height ?? (isBuiltin ? 1107 : 1440)

            let natAspect = Double(natW) / Double(max(natH, 1))
            let sliderModes = allModes
                .filter {
                    $0.width >= 1280 &&
                    $0.width <= natW &&
                    abs(Double($0.width) / Double(max($0.height, 1)) - natAspect) < 0.03
                }
                .sorted { a, b in
                    if a.width != b.width { return a.width < b.width }
                    return a.isHiDPI && !b.isHiDPI
                }
                .reduce(into: [DisplayModeItem]()) { acc, item in
                    // Prefer HiDPI variant at each width for the resolution slider
                    if let lastIdx = acc.indices.last, acc[lastIdx].width == item.width {
                        if item.isHiDPI && !acc[lastIdx].isHiDPI {
                            acc[lastIdx] = item
                        }
                    } else {
                        acc.append(item)
                    }
                }

            let info = DisplayInfo(
                id: did,
                uuid: uuid,
                name: name,
                vendorID: vendorID,
                productID: productID,
                isBuiltin: isBuiltin,
                isVirtual: isVirtual,
                isMain: isMain,
                isEnabled: isEnabled,
                currentWidth: curW,
                currentHeight: curH,
                currentPixelWidth: curPW,
                currentPixelHeight: curPH,
                currentRefreshRate: curHz == 0 ? 60 : curHz,
                bitDepth: hwBpc,
                isCurrentHiDPI: isCurHiDPI,
                nativeWidth: natW,
                nativeHeight: natH,
                modes: allModes,
                sliderModes: sliderModes
            )
            built.append(info)

            if adjustmentsByUUID[uuid] == nil {
                adjustmentsByUUID[uuid] = ImageAdjustments()
            }
            if isBuiltin {
                var hwB: Float = 0.5
                if DisplayServicesGetBrightness(did, &hwB) == 0 {
                    adjustmentsByUUID[uuid]?.combinedBrightness = Double(hwB)
                }
            }
        }

        // Keep any software-disabled displays visible in the header list so the user can toggle them back on
        let onlineUUIDs = Set(built.map(\.uuid))
        for (uuid, cachedDisp) in disabledDisplaysByUUID {
            if onlineUUIDs.contains(uuid) {
                disabledDisplaysByUUID.removeValue(forKey: uuid)
            } else {
                built.append(cachedDisp)
            }
        }

        // Sort: External displays first (since user's primary target is HP Z27u G3), then Built-in
        built.sort { a, b in
            if a.isBuiltin != b.isBuiltin { return !a.isBuiltin }
            return a.id < b.id
        }

        displays = built
        if selectedDisplayUUID.isEmpty || !built.contains(where: { $0.uuid == selectedDisplayUUID }) {
            selectedDisplayUUID = built.first?.uuid ?? ""
        }
        draggingSliderIndex = nil
    }

    static func displayUUID(for displayID: CGDirectDisplayID) -> String {
        if let uuidRef = CGDisplayCreateUUIDFromDisplayID(displayID)?.takeRetainedValue(),
           let str = CFUUIDCreateString(kCFAllocatorDefault, uuidRef) as String? {
            return str
        }
        return String(format: "%04X-%04X-%d", CGDisplayVendorNumber(displayID), CGDisplayModelNumber(displayID), displayID)
    }

    static func hardwareBitDepth(for displayID: CGDirectDisplayID, vendorID: Int, productID: Int, isBuiltin: Bool) -> Int {
        // 1. Check active hardware ColorElements on IOMobileFramebufferShim in IORegistry
        var iter = io_iterator_t()
        if IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOMobileFramebufferShim"), &iter) == KERN_SUCCESS {
            defer { IOObjectRelease(iter) }
            while case let entry = IOIteratorNext(iter), entry != IO_OBJECT_NULL {
                defer { IOObjectRelease(entry) }
                guard let da = IORegistryEntryCreateCFProperty(entry, "DisplayAttributes" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? [String: Any],
                      let prod = da["ProductAttributes"] as? [String: Any] else { continue }
                let entryPID = prod["ProductID"] as? Int ?? -1
                let entryVID = prod["LegacyManufacturerID"] as? Int ?? -1
                let mfgID = prod["ManufacturerID"] as? String ?? ""
                let matches = isBuiltin ? (mfgID == "00-10-fa" || entryVID == 1552) : (entryPID == productID && entryVID == vendorID)
                if matches,
                   let elements = IORegistryEntryCreateCFProperty(entry, "ColorElements" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? [[String: Any]] {
                    let physical = elements.filter {
                        ($0["IsVirtual"] as? Bool) == false &&
                        ($0["DynamicRange"] as? Int ?? 0) == 0 &&
                        ($0["EOTF"] as? Int ?? 0) == 0
                    }
                    if let best = physical.max(by: { ($0["Score"] as? Int ?? 0) < ($1["Score"] as? Int ?? 0) }),
                       let depth = best["Depth"] as? Int, depth > 0 {
                        return depth
                    }
                }
            }
        }
        // 2. Fallback to SkyLight CGSDisplayModeDescription.depth
        var desc = CGSDisplayModeDescription()
        if CGSGetDisplayModeDescriptionOfLength(displayID, 0, &desc, Int32(MemoryLayout<CGSDisplayModeDescription>.size)) == .success,
           desc.depth > 0 {
            return Int(desc.depth)
        }
        return 8
    }

    static func enumerateModes(for displayID: CGDirectDisplayID, defaultBitDepth: Int = 8) -> [DisplayModeItem] {
        let opts: CFDictionary = [kCGDisplayShowDuplicateLowResolutionModes: kCFBooleanTrue] as CFDictionary
        guard let cfModes = CGDisplayCopyAllDisplayModes(displayID, opts) as? [CGDisplayMode] else {
            return []
        }

        var depthByModeNumber: [Int32: Int] = [:]
        var nCGSModes: Int32 = 0
        if CGSGetNumberOfDisplayModes(displayID, &nCGSModes) == .success {
            for idx in 0..<nCGSModes {
                var desc = CGSDisplayModeDescription()
                if CGSGetDisplayModeDescriptionOfLength(displayID, idx, &desc, Int32(MemoryLayout<CGSDisplayModeDescription>.size)) == .success,
                   desc.depth > 0 {
                    depthByModeNumber[Int32(desc.displayModeNumber)] = Int(desc.depth)
                }
            }
        }
        var seen = Set<String>()
        var result: [DisplayModeItem] = []

        for m in cfModes {
            let w = m.width
            let h = m.height
            let pw = m.pixelWidth
            let ph = m.pixelHeight
            guard w >= 640, h >= 480 else { continue }
            let hz = Int(round(m.refreshRate == 0 ? 60.0 : m.refreshRate))
            let isHiDPI = pw > w
            let isNative = (m.ioFlags & UInt32(kDisplayModeNativeFlag)) != 0
            let key = "\(w)x\(h)-\(isHiDPI ? "hi" : "lo")-\(hz)"
            if seen.contains(key) { continue }
            seen.insert(key)

            result.append(DisplayModeItem(
                id: key,
                modeRef: m,
                ioModeID: m.ioDisplayModeID,
                width: w,
                height: h,
                pixelWidth: pw,
                pixelHeight: ph,
                refreshRate: hz,
                bitDepth: depthByModeNumber[m.ioDisplayModeID] ?? defaultBitDepth,
                isHiDPI: isHiDPI,
                isNative: isNative
            ))
        }

        result.sort { a, b in
            if a.width != b.width { return a.width > b.width }
            if a.height != b.height { return a.height > b.height }
            if a.isHiDPI != b.isHiDPI { return a.isHiDPI && !b.isHiDPI }
            return a.refreshRate > b.refreshRate
        }
        return result
    }

    // MARK: - Resolution & Display Controls

    func setDisplayMode(_ item: DisplayModeItem, for display: DisplayInfo? = nil) {
        guard let disp = display ?? selectedDisplay else { return }
        var config: CGDisplayConfigRef?
        if CGBeginDisplayConfiguration(&config) == .success, let cfg = config {
            CGConfigureDisplayWithDisplayMode(cfg, disp.id, item.modeRef, nil)
            CGCompleteDisplayConfiguration(cfg, .permanently)
        } else {
            CGDisplaySetDisplayMode(disp.id, item.modeRef, nil)
        }
        statusMessage = "Set \(disp.name) to \(item.width)×\(item.height) \(item.isHiDPI ? "HiDPI" : "LoDPI")"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.refreshDisplays()
            self.applyAllAdjustments()
        }
    }

    func toggleHiDPIForCurrentResolution() {
        guard let disp = selectedDisplay else { return }
        let targetHiDPI = !disp.isCurrentHiDPI
        if let match = disp.modes.first(where: {
            $0.width == disp.currentWidth && $0.height == disp.currentHeight && $0.isHiDPI == targetHiDPI
        }) {
            setDisplayMode(match, for: disp)
            return
        }
        // Never jump to a completely different resolution (like 1280x720 mega-jumbo)!
        if targetHiDPI {
            statusMessage = "Click 'Install Override…' below to unlock \(disp.currentWidth)×\(disp.currentHeight) HiDPI"
        } else {
            statusMessage = "No 1× LoDPI variant at \(disp.currentWidth)×\(disp.currentHeight)"
        }
    }

    func setAsMainDisplay(_ display: DisplayInfo? = nil) {
        guard let disp = display ?? selectedDisplay, !disp.isMain else { return }
        let targetBounds = CGDisplayBounds(disp.id)
        let dx = -Int32(targetBounds.origin.x)
        let dy = -Int32(targetBounds.origin.y)

        var config: CGDisplayConfigRef?
        guard CGBeginDisplayConfiguration(&config) == .success, let cfg = config else { return }
        for d in displays {
            let b = CGDisplayBounds(d.id)
            let newX = d.id == disp.id ? 0 : Int32(b.origin.x) + dx
            let newY = d.id == disp.id ? 0 : Int32(b.origin.y) + dy
            CGConfigureDisplayOrigin(cfg, d.id, newX, newY)
        }
        CGCompleteDisplayConfiguration(cfg, .permanently)
        statusMessage = "\(disp.name) is now Main Display"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.refreshDisplays()
        }
    }

    func toggleDisplayEnabled(_ display: DisplayInfo) {
        let activeCount = displays.filter(\.isEnabled).count
        if display.isEnabled && activeCount <= 1 {
            statusMessage = "Cannot disable the only active display"
            return
        }
        let targetState = !display.isEnabled
        var config: CGDisplayConfigRef?
        guard CGBeginDisplayConfiguration(&config) == .success, let cfg = config else {
            statusMessage = "Failed to begin display configuration"
            return
        }
        guard CGSConfigureDisplayEnabled(cfg, display.id, targetState) == .success,
              CGCompleteDisplayConfiguration(cfg, .forSession) == .success else {
            if let cfg = config { CGCancelDisplayConfiguration(cfg) }
            statusMessage = "Could not \(targetState ? "connect" : "disconnect") \(display.name)"
            return
        }
        if !targetState {
            disabledDisplaysByUUID[display.uuid] = DisplayInfo(
                id: display.id,
                uuid: display.uuid,
                name: display.name,
                vendorID: display.vendorID,
                productID: display.productID,
                isBuiltin: display.isBuiltin,
                isVirtual: display.isVirtual,
                isMain: false,
                isEnabled: false,
                currentWidth: display.currentWidth,
                currentHeight: display.currentHeight,
                currentPixelWidth: display.currentPixelWidth,
                currentPixelHeight: display.currentPixelHeight,
                currentRefreshRate: display.currentRefreshRate,
                bitDepth: display.bitDepth,
                isCurrentHiDPI: display.isCurrentHiDPI,
                nativeWidth: display.nativeWidth,
                nativeHeight: display.nativeHeight,
                modes: display.modes,
                sliderModes: display.sliderModes
            )
        } else {
            disabledDisplaysByUUID.removeValue(forKey: display.uuid)
        }
        statusMessage = "\(targetState ? "Connected" : "Disconnected") \(display.name)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.refreshDisplays()
            self.applyAllAdjustments()
        }
    }

    func reenableAllDisplays() {
        let candidateIDs = Set(disabledDisplaysByUUID.values.map(\.id)).union([1, 2, 3, 4, 5, 6])
        for did in candidateIDs {
            var config: CGDisplayConfigRef?
            if CGBeginDisplayConfiguration(&config) == .success, let cfg = config {
                _ = CGSConfigureDisplayEnabled(cfg, did, true)
                CGCompleteDisplayConfiguration(cfg, .forSession)
            }
        }
        disabledDisplaysByUUID.removeAll()
    }

    // MARK: - Flexible HiDPI System Override Installer (HP Z27u G3 & External Displays)

    func buildOverridePlistXML(for display: DisplayInfo) -> String {
        let natW = max(display.nativeWidth, 2560)
        let natH = max(display.nativeHeight, 1440)
        var dataEntries: [String] = []

        // Generate 16px steps from nativeW down to 1280, always emitting BOTH 2x backing and 1x logical
        // so macOS WindowServer unlocks HiDPI for every intermediate step (e.g. 2336x1314 -> 4672x2628)
        var w = natW
        while w >= 1280 {
            let h = Int(round(Double(w) * Double(natH) / Double(natW)))
            let pairs = [(w * 2, h * 2), (w, h)]
            for (rw, rh) in pairs {
                // 8-byte record (width BE, height BE)
                var b8 = [UInt8](repeating: 0, count: 8)
                b8[0] = UInt8((rw >> 24) & 0xFF)
                b8[1] = UInt8((rw >> 16) & 0xFF)
                b8[2] = UInt8((rw >> 8) & 0xFF)
                b8[3] = UInt8(rw & 0xFF)
                b8[4] = UInt8((rh >> 24) & 0xFF)
                b8[5] = UInt8((rh >> 16) & 0xFF)
                b8[6] = UInt8((rh >> 8) & 0xFF)
                b8[7] = UInt8(rh & 0xFF)
                dataEntries.append("\t\t<data>\(Data(b8).base64EncodedString())</data>")

                // 12-byte HiDPI record (width BE, height BE, 0x00000001)
                let b12 = b8 + [0, 0, 0, 1]
                dataEntries.append("\t\t<data>\(Data(b12).base64EncodedString())</data>")

                // 16-byte extended HiDPI record (width BE, height BE, 0x00000001, 0x00200000)
                let b16 = b12 + [0, 0x20, 0, 0]
                dataEntries.append("\t\t<data>\(Data(b16).base64EncodedString())</data>")
            }
            w -= 16
        }

        let entriesJoined = dataEntries.joined(separator: "\n")
        let escapedName = display.name
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        \t<key>DisplayProductName</key>
        \t<string>\(escapedName)</string>
        \t<key>DisplayVendorID</key>
        \t<integer>\(display.vendorID)</integer>
        \t<key>DisplayProductID</key>
        \t<integer>\(display.productID)</integer>
        \t<key>IOGFlags</key>
        \t<integer>4</integer>
        \t<key>scale-resolutions</key>
        \t<array>
        \(entriesJoined)
        \t</array>
        </dict>
        </plist>
        """
    }

    func installSystemFlexibleScalingOverride(for display: DisplayInfo? = nil) {
        guard let disp = display ?? selectedDisplay else { return }
        let xml = buildOverridePlistXML(for: disp)
        let tmpPath = "/tmp/DisplayProductID-\(String(format: "%x", disp.productID)).plist"
        do {
            try xml.write(toFile: tmpPath, atomically: true, encoding: .utf8)
        } catch {
            statusMessage = "Failed writing temp override: \(error.localizedDescription)"
            return
        }

        let dirPath = String(format: "/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-%x", disp.vendorID)
        let destPath = disp.overridePlistPath
        let cmd = "mkdir -p '\(dirPath)' && cp '\(tmpPath)' '\(destPath)' && chmod 644 '\(destPath)' && defaults write /Library/Preferences/com.apple.windowserver.plist DisplayResolutionEnabled -bool true"
        let scriptSrc = "do shell script \"\(cmd)\" with administrator privileges"

        if let script = NSAppleScript(source: scriptSrc) {
            var errDict: NSDictionary?
            script.executeAndReturnError(&errDict)
            if let err = errDict {
                statusMessage = "Admin install cancelled/failed: \(err["NSAppleScriptErrorBriefMessage"] ?? "")"
            } else {
                // Reinitialize external display so WindowServer reloads override
                reinitializeDisplay(disp)
                statusMessage = "Installed Flexible HiDPI Override at \(destPath)"
            }
        }
        refreshDisplays()
    }

    func reinitializeDisplay(_ display: DisplayInfo) {
        guard !display.isBuiltin else { return }
        var cfg1: CGDisplayConfigRef?
        if CGBeginDisplayConfiguration(&cfg1) == .success, let c1 = cfg1 {
            _ = CGSConfigureDisplayEnabled(c1, display.id, false)
            CGCompleteDisplayConfiguration(c1, .forSession)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var cfg2: CGDisplayConfigRef?
            if CGBeginDisplayConfiguration(&cfg2) == .success, let c2 = cfg2 {
                _ = CGSConfigureDisplayEnabled(c2, display.id, true)
                CGCompleteDisplayConfiguration(c2, .forSession)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.refreshDisplays()
                self.applyAllAdjustments()
            }
        }
    }

    // MARK: - Color Table (LUT) & Hardware Brightness/Volume Execution

    func applyAllAdjustments() {
        for disp in displays where disp.isEnabled {
            let adj = adjustmentsByUUID[disp.uuid] ?? ImageAdjustments()
            applyAdjustments(for: disp, adjustments: adj)
        }
    }

    func setCombinedBrightness(_ val: Double) {
        guard let disp = selectedDisplay else { return }
        let clamped = max(0.05, min(1.0, val))
        var adj = currentAdjustments
        adj.combinedBrightness = clamped
        adjustmentsByUUID[disp.uuid] = adj
        saveAdjustments()

        if disp.isBuiltin {
            _ = DisplayServicesSetBrightness(disp.id, Float(clamped))
        } else {
            let ddcVal = UInt16(round(clamped * 100.0))
            DDCController.shared.write(vcp: .brightness, value: ddcVal, throttleKey: "b-\(disp.uuid)")
        }
        applyAdjustments(for: disp, adjustments: adj)
    }

    func applyAdjustments(for display: DisplayInfo, adjustments: ImageAdjustments) {
        let b = max(0.05, min(1.0, adjustments.combinedBrightness))
        let lutBrightnessScale: Double
        if display.isBuiltin {
            lutBrightnessScale = b < 0.15 ? max(0.25, b / 0.15) : 1.0
        } else {
            lutBrightnessScale = max(0.10, 0.15 + 0.85 * b)
        }
        // 2. Color Table (256-entry 1D LUT per channel via CGSetDisplayTransferByTable)
        if !adjustments.enableColorTable || adjustments.suspended || (adjustments.isLUTNeutral && abs(lutBrightnessScale - 1.0) < 0.005) {
            var r = (0..<256).map { Float($0) / 255.0 }
            var g = r
            var bl = r
            _ = CGSetDisplayTransferByTable(display.id, 256, &r, &g, &bl)
        } else {
            var rTable = Self.computeChannelLUT(
                channelIndex: 0,
                brightnessScale: lutBrightnessScale,
                adj: adjustments
            )
            var gTable = Self.computeChannelLUT(
                channelIndex: 1,
                brightnessScale: lutBrightnessScale,
                adj: adjustments
            )
            var bTable = Self.computeChannelLUT(
                channelIndex: 2,
                brightnessScale: lutBrightnessScale,
                adj: adjustments
            )
            _ = CGSetDisplayTransferByTable(display.id, 256, &rTable, &gTable, &bTable)
        }

        // 3. Compositor Filter Overlay (Saturation, Vibrance, Hue, Sepia)
        CompositorOverlayManager.shared.updateOverlay(for: display.id, adjustments: adjustments)
    }

    static func computeChannelLUT(channelIndex: Int, brightnessScale: Double, adj: ImageAdjustments) -> [Float] {
        // Temperature multiplier: Warm (+temp) boosts Red, reduces Blue; Cool (-temp) boosts Blue, reduces Red
        let temp = adj.colorTemperature // -0.5 .. +0.5
        let tempMult: Double
        switch channelIndex {
        case 0: // Red
            tempMult = temp >= 0 ? 1.0 : max(0.4, 1.0 + temp * 0.9)
        case 1: // Green
            tempMult = max(0.6, 1.0 - abs(temp) * 0.25)
        default: // Blue
            tempMult = temp <= 0 ? 1.0 : max(0.3, 1.0 - temp * 1.1)
        }

        let chGammaOffset = (channelIndex == 0 ? adj.gammaRed : (channelIndex == 1 ? adj.gammaGreen : adj.gammaBlue))
        let chGainOffset = (channelIndex == 0 ? adj.gainRed : (channelIndex == 1 ? adj.gainGreen : adj.gainBlue))

        // Effective gamma exponent: 0.0 -> 1.0; +0.5 -> 0.5 (brighter midtones); -0.5 -> 2.0 (darker midtones)
        let totalGamma = max(-0.85, min(0.85, adj.gamma + chGammaOffset))
        let gammaExp = pow(2.0, -totalGamma * 1.6)

        // Effective gain multiplier
        let totalGain = max(0.08, (1.0 + adj.gain + chGainOffset) * brightnessScale * tempMult)

        // Contrast slope around midpoint 0.5
        let contrastSlope = pow(2.5, adj.contrast * 1.8)

        let quantSteps = max(4.0, min(256.0, round(adj.quantization)))

        var table = [Float](repeating: 0, count: 256)
        for i in 0..<256 {
            var x = Double(i) / 255.0

            // Quantization (posterization)
            if quantSteps < 255.0 {
                x = round(x * (quantSteps - 1.0)) / (quantSteps - 1.0)
            }

            // Shadow & Highlight S-curve shaping
            if abs(adj.shadow) > 0.001 {
                x += adj.shadow * 0.65 * x * pow(1.0 - x, 2.0) * 4.0
            }
            if abs(adj.highlight) > 0.001 {
                x += adj.highlight * 0.65 * pow(x, 2.0) * (1.0 - x) * 4.0
            }
            x = max(0.0, min(1.0, x))

            // Contrast around 0.5
            x = (x - 0.5) * contrastSlope + 0.5
            x = max(0.0, min(1.0, x))

            // Gamma curve
            x = pow(x, gammaExp)

            // Gain & Temperature & Software Brightness
            x *= totalGain

            table[i] = Float(max(0.0, min(1.0, x)))
        }

        // Black-screen safety guard: ensure peak white never drops below 0.08
        if table[255] < 0.08 {
            for i in 0..<256 {
                table[i] = Float(Double(i) / 255.0 * 0.08)
            }
        }
        return table
    }

    private func enforceLUTIfDrifted() {
        for disp in displays where disp.isEnabled {
            guard let adj = adjustmentsByUUID[disp.uuid],
                  adj.enableColorTable,
                  !adj.suspended,
                  (!adj.isLUTNeutral || adj.combinedBrightness < 0.99) else { continue }

            var r = [Float](repeating: 0, count: 256)
            var g = [Float](repeating: 0, count: 256)
            var b = [Float](repeating: 0, count: 256)
            var count: UInt32 = 0
            if CGGetDisplayTransferByTable(disp.id, 256, &r, &g, &b, &count) == .success {
                // If WindowServer reset LUT back to linear identity (r[255]==1, g[255]==1, b[255]==1, r[128]≈0.502), re-apply
                applyAdjustments(for: disp, adjustments: adj)
            }
        }
    }

    func setVolume(_ vol: Double) {
        var adj = currentAdjustments
        adj.volume = max(0.0, min(1.0, vol))
        currentAdjustments = adj

        guard let disp = selectedDisplay else { return }
        if !disp.isBuiltin {
            DDCController.shared.write(vcp: .volume, value: UInt16(round(adj.volume * 100.0)), throttleKey: "vol-\(disp.uuid)")
        } else {
            let pct = Int(round(adj.volume * 100.0))
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            proc.arguments = ["-e", "set volume output volume \(pct)"]
            try? proc.run()
        }
    }

    func setHardwareSharpness(_ val: Double) {
        var adj = currentAdjustments
        adj.hardwareSharpness = max(0.0, min(1.0, val))
        currentAdjustments = adj
        guard let disp = selectedDisplay, !disp.isBuiltin else { return }
        DDCController.shared.write(vcp: .sharpness, value: UInt16(round(adj.hardwareSharpness * 100.0)), throttleKey: "sharp-\(disp.uuid)")
    }

    func resetAllDisplays() {
        reenableAllDisplays()
        CGDisplayRestoreColorSyncSettings()
        CompositorOverlayManager.shared.removeAll()
        for disp in displays {
            adjustmentsByUUID[disp.uuid]?.resetColors()
            if disp.isBuiltin {
                var hwB: Float = 0.5
                if DisplayServicesGetBrightness(disp.id, &hwB) == 0 {
                    adjustmentsByUUID[disp.uuid]?.combinedBrightness = Double(hwB)
                }
            } else {
                adjustmentsByUUID[disp.uuid]?.combinedBrightness = 1.0
            }
        }
        saveAdjustments()
        statusMessage = "Reset all display adjustments to factory defaults"
    }

    // MARK: - Font Smoothing (Text Clarity)

    func loadFontSmoothing() {
        let proc = Process()
        let pipe = Pipe()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        proc.arguments = ["-currentHost", "read", "-g", "AppleFontSmoothing"]
        proc.standardOutput = pipe
        proc.standardError = FileHandle.nullDevice
        try? proc.run()
        proc.waitUntilExit()
        if let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           let val = Int(out) {
            fontSmoothingLevel = max(0, min(3, val))
        }
    }

    func setFontSmoothing(_ level: Int) {
        let clamped = max(0, min(3, level))
        fontSmoothingLevel = clamped
        let p1 = Process()
        p1.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        p1.arguments = ["-currentHost", "write", "-g", "AppleFontSmoothing", "-int", "\(clamped)"]
        try? p1.run()
        p1.waitUntilExit()

        let p2 = Process()
        p2.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        p2.arguments = ["write", "-g", "CGFontRenderingFontSmoothingDisabled", "-bool", clamped == 0 ? "true" : "false"]
        try? p2.run()
        p2.waitUntilExit()

        statusMessage = "Set macOS Font Smoothing to \(clamped) (reopen apps to apply)"
    }

    // MARK: - Persistence

    private func saveAdjustments() {
        if let data = try? JSONEncoder().encode(adjustmentsByUUID) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func loadSavedAdjustments() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String: ImageAdjustments].self, from: data) {
            adjustmentsByUUID = decoded
        }
    }

    func isFavoriteMode(_ item: DisplayModeItem, for disp: DisplayInfo) -> Bool {
        favoriteModeIDsByUUID[disp.uuid]?.contains(item.id) ?? false
    }

    func toggleFavoriteMode(_ item: DisplayModeItem, for disp: DisplayInfo) {
        var list = favoriteModeIDsByUUID[disp.uuid] ?? []
        if let idx = list.firstIndex(of: item.id) {
            list.remove(at: idx)
            statusMessage = "Removed \(item.width)×\(item.height) from favorites"
        } else {
            list.append(item.id)
            statusMessage = "Added \(item.width)×\(item.height) to favorites"
        }
        favoriteModeIDsByUUID[disp.uuid] = list
        if let data = try? JSONEncoder().encode(favoriteModeIDsByUUID) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            favoriteModeIDsByUUID = decoded
        }
    }

    // MARK: - Launch at Login (~/Library/LaunchAgents/com.local.DisplayControl.plist)

    private var launchAgentURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.local.DisplayControl.plist")
    }

    private func loadLaunchAtLogin() {
        let exists = FileManager.default.fileExists(atPath: launchAgentURL.path)
        if !exists && !UserDefaults.standard.bool(forKey: "DisplayControl.LaunchAgentInitialized") {
            UserDefaults.standard.set(true, forKey: "DisplayControl.LaunchAgentInitialized")
            setLaunchAtLogin(true)
        } else {
            launchAtLogin = exists
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        launchAtLogin = enabled
        let fm = FileManager.default
        if enabled {
            let dir = launchAgentURL.deletingLastPathComponent()
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
            let plist = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
            \t<key>Label</key>
            \t<string>com.local.DisplayControl</string>
            \t<key>ProgramArguments</key>
            \t<array>
            \t\t<string>/Applications/DisplayControl.app/Contents/MacOS/DisplayControl</string>
            \t\t<string>--background</string>
            \t</array>
            \t<key>RunAtLoad</key>
            \t<true/>
            </dict>
            </plist>
            """
            try? plist.write(to: launchAgentURL, atomically: true, encoding: .utf8)
            statusMessage = "Enabled Launch at Login"
        } else {
            try? fm.removeItem(at: launchAgentURL)
            statusMessage = "Disabled Launch at Login"
        }
    }
}

// MARK: - SwiftUI Menu Bar Interface (Matching BetterDisplay Dark Popover Layout)


// MARK: - Reusable Slider Row Component (with Double-Click / Reset Button)


// MARK: - App Delegate & Display Reconfiguration Callback

private func displayReconfigCallback(
    display: CGDirectDisplayID,
    flags: CGDisplayChangeSummaryFlags,
    userInfo: UnsafeMutableRawPointer?
) {
    if flags.contains(.beginConfigurationFlag) { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        DisplayManager.shared.refreshDisplays()
        DisplayManager.shared.applyAllAdjustments()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    static weak var shared: AppDelegate?
    private let popover = NSPopover()
    private var terminationSignals: [DispatchSourceSignal] = []
    private var resizeWorkItem: DispatchWorkItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        CGDisplayRegisterReconfigurationCallback(displayReconfigCallback, nil)
        Self.shared = self
        for sig in [SIGTERM, SIGINT] {
            Darwin.signal(sig, SIG_IGN)
            let src = DispatchSource.makeSignalSource(signal: sig, queue: .main)
            src.setEventHandler { NSApplication.shared.terminate(nil) }
            src.resume()
            terminationSignals.append(src)
        }

        popover.contentSize = NSSize(width: PopoverLayoutMetrics.width, height: PopoverLayoutMetrics.totalHeight(for: DisplayManager.shared))
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: MenuPopoverView())

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "DisplayControl")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Global Panic Reset Shortcut: Cmd + Opt + Shift + R
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.command, .option, .shift], event.charactersIgnoringModifiers?.lowercased() == "r" {
                DispatchQueue.main.async {
                    DisplayManager.shared.resetAllDisplays()
                }
            }
        }

        let args = CommandLine.arguments
        if let subIdx = args.firstIndex(of: "--submenu"), subIdx + 1 < args.count {
            switch args[subIdx + 1] {
            case "displayMode": DisplayManager.shared.activeSubmenu = .displayMode
            case "imageAdjustments": DisplayManager.shared.activeSubmenu = .imageAdjustments
            case "textClarity": DisplayManager.shared.activeSubmenu = .textClarity
            case "systemColors": DisplayManager.shared.activeSubmenu = .systemColors
            default: DisplayManager.shared.activeSubmenu = .none
            }
        }
        if args.contains("--manage-favorites") {
            DisplayManager.shared.isManagingFavorites = true
        }
        if !args.contains("--background") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.showPopover()
            }
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            showPopover()
        }
    }

    func showPopover() {
        guard let button = statusItem.button else { return }
        DisplayManager.shared.refreshDisplays()
        popover.contentSize = NSSize(width: PopoverLayoutMetrics.width, height: PopoverLayoutMetrics.totalHeight(for: DisplayManager.shared))
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    func updatePopoverSize(width: CGFloat, height: CGFloat) {
        let target = NSSize(width: width, height: height)
        resizeWorkItem?.cancel()
        guard abs(popover.contentSize.height - target.height) > 0.5 || abs(popover.contentSize.width - target.width) > 0.5 else {
            return
        }
        if target.height >= popover.contentSize.height {
            popover.contentSize = target
        } else {
            // Delay shrinking the NSPopover window until the 0.22s SwiftUI collapse animation finishes
            let work = DispatchWorkItem { [weak self] in
                self?.popover.contentSize = target
            }
            resizeWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22, execute: work)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        DisplayManager.shared.reenableAllDisplays()
        CompositorOverlayManager.shared.removeAll()
    }
}

// MARK: - CLI & Entry Point

@main
struct DisplayControlApp {
    static func main() {
        let args = CommandLine.arguments
        if args.count > 1 && args[1].hasPrefix("--") && args[1] != "--background" && args[1] != "--submenu" && args[1] != "--manage-favorites" {
            runCLI(args: Array(args.dropFirst()))
            exit(0)
        }
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    static func runCLI(args: [String]) {
        let mgr = DisplayManager.shared
        mgr.refreshDisplays()

        switch args[0] {
        case "--status":
            print("Connected Displays (\(mgr.displays.count)):")
            for d in mgr.displays {
                print("  - [\(d.id)] \(d.name) | UUID: \(d.uuid) | \(d.currentWidth)x\(d.currentHeight) (backing \(d.currentPixelWidth)x\(d.currentPixelHeight)) \(d.isCurrentHiDPI ? "HiDPI (2x)" : "LoDPI (1x)") @\(d.currentRefreshRate)Hz \(d.bitDepth)-bit | Main: \(d.isMain) | Modes: \(d.modes.count)")
            }
            print("System Colors: DarkMode=\(mgr.isDarkMode) TrueTone=\(mgr.isTrueToneEnabled) NightShift=\(mgr.isNightShiftEnabled) (strength=\(String(format: "%.2f", mgr.nightShiftStrength))) FontSmoothing=\(mgr.fontSmoothingLevel)")

        case "--set-brightness":
            // --set-brightness <displayID|external|builtin> <0..100>
            guard args.count >= 3, let pct = Double(args[2]) else {
                print("Usage: --set-brightness <external|builtin|id> <0..100>")
                return
            }
            if let disp = matchDisplay(arg: args[1], in: mgr.displays) {
                mgr.selectedDisplayUUID = disp.uuid
                mgr.setCombinedBrightness(pct / 100.0)
                print("Set brightness on \(disp.name) to \(Int(pct))%")
            }

        case "--set-color":
            // --set-color <external|builtin|id> <contrast> <gamma> <gain> <temp>
            guard args.count >= 6,
                  let c = Double(args[2]),
                  let gm = Double(args[3]),
                  let gn = Double(args[4]),
                  let t = Double(args[5]),
                  let disp = matchDisplay(arg: args[1], in: mgr.displays) else {
                print("Usage: --set-color <external|builtin|id> <contrast -50..50> <gamma -50..50> <gain -50..50> <temp -50..50>")
                return
            }
            mgr.selectedDisplayUUID = disp.uuid
            var adj = mgr.currentAdjustments
            adj.contrast = c / 100.0
            adj.gamma = gm / 100.0
            adj.gain = gn / 100.0
            adj.colorTemperature = t / 100.0
            mgr.currentAdjustments = adj
            print("Applied LUT color adjustments on \(disp.name): contrast=\(c)% gamma=\(gm)% gain=\(gn)% temp=\(t)%")

        case "--set-mode":
            // --set-mode <external|builtin|id> <width> <height> [hidpi|lodpi]
            guard args.count >= 4,
                  let w = Int(args[2]),
                  let h = Int(args[3]),
                  let disp = matchDisplay(arg: args[1], in: mgr.displays) else {
                print("Usage: --set-mode <external|builtin|id> <width> <height> [hidpi|lodpi]")
                return
            }
            let wantHiDPI = args.count >= 5 ? (args[4].lowercased() == "hidpi") : nil
            if let m = disp.modes.first(where: {
                $0.width == w && $0.height == h && (wantHiDPI == nil || $0.isHiDPI == wantHiDPI)
            }) {
                mgr.setDisplayMode(m, for: disp)
                print("Switched \(disp.name) to \(m.width)x\(m.height) (\(m.isHiDPI ? "HiDPI" : "LoDPI"))")
            } else {
                print("Mode \(w)x\(h) not found in \(disp.name)'s current mode list")
            }

        case "--toggle-favorite":
            guard args.count >= 4,
                  let w = Int(args[2]),
                  let h = Int(args[3]),
                  let disp = matchDisplay(arg: args[1], in: mgr.displays) else {
                print("Usage: --toggle-favorite <external|builtin|id> <width> <height> [hidpi|lodpi]")
                return
            }
            let wantHiDPI = args.count >= 5 ? (args[4].lowercased() == "hidpi") : nil
            if let m = disp.modes.first(where: {
                $0.width == w && $0.height == h && (wantHiDPI == nil || $0.isHiDPI == wantHiDPI)
            }) {
                mgr.toggleFavoriteMode(m, for: disp)
                print(mgr.statusMessage)
            } else {
                print("Mode \(w)x\(h) not found on \(disp.name)")
            }

        case "--write-override-plist":
            // Writes the generated override plist to /tmp for inspection or manual install
            guard let disp = mgr.displays.first(where: { !$0.isBuiltin }) ?? mgr.displays.first else { return }
            let xml = mgr.buildOverridePlistXML(for: disp)
            let path = "/tmp/DisplayProductID-\(String(format: "%x", disp.productID)).plist"
            try? xml.write(toFile: path, atomically: true, encoding: .utf8)
            print("Wrote override plist for \(disp.name) (\(disp.overridePlistPath)) to \(path)")

        case "--reset":
            mgr.resetAllDisplays()
            print("Reset all displays to factory LUT/compositor defaults.")

        default:
            print("Unknown flag: \(args[0])")
        }
    }

    private static func matchDisplay(arg: String, in list: [DisplayInfo]) -> DisplayInfo? {
        if arg == "external" { return list.first(where: { !$0.isBuiltin }) }
        if arg == "builtin" { return list.first(where: { $0.isBuiltin }) }
        if let id = UInt32(arg) { return list.first(where: { $0.id == id }) }
        return list.first
    }
}
