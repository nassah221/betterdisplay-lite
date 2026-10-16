# AGENTS.md — DisplayControl (BetterDisplayLite)

Architecture, build constraints, and hard-won macOS 26+ (`arm64-apple-macosx26.0`) patterns for working on this repository.

---

## 1. Project Overview & File Map

`DisplayControl` is a zero-dependency native macOS 26+ menu bar controller for display resolutions, Flexible HiDPI scaling, hardware DDC/CI, software 1D LUT color tables, compositor filters, and system color settings.

| File | Responsibility |
|---|---|
| `DisplayControl.swift` | Private/public framework bridges (`CoreGraphics`, `SkyLight`, `CoreDisplay`, `DisplayServices`, `IOKit`, `CoreBrightness`), `DisplayManager` state & persistence, `DDCController`, `CompositorOverlayManager`, `SystemColorsController`, `AppDelegate` (`NSStatusItem` + `NSPopover`), and CLI entrypoint. |
| `Components.swift` | Control Center / Liquid Glass UI primitives: `ArrowCursorNSSlider` / `NativeLiquidGlassSlider`, `CCSlider`, `CCMenuRow`, `CCToggleCircleRow`, `CCModeBadge`, and `CCExpandableSection`. |
| `Subpanels.swift` | Drill-down subpanel bodies: `DisplayModeSubpanel` (with Favorites management), `ImageAdjustmentsSubpanel` (17 color/LUT/compositor sliders + bottom `Enable Color Table Control` / `Suspend All Adjustments` / `Reset All Adjustments`), `TextClaritySubpanel`, and `SystemColorsSubpanel`. |
| `MenuPopoverView.swift` | `PopoverLayoutMetrics` (single source of truth for screen-derived dynamic popover height) and root `MenuPopoverView`. |
| `build.sh` | Compiles all `.swift` files with `swiftc -target arm64-apple-macosx26.0 -parse-as-library -O`, writes `Info.plist` (`LSMinimumSystemVersion = 26.0`, `LSUIElement = true`), and ad-hoc signs `/Applications/DisplayControl.app`. |

---

## 2. Build & Toolchain Invariants

1. **No `@State` Macro (CommandLineTools Compatibility):**
   - CommandLineTools SDK builds (`MacOSX27.0.sdk`) do not ship the `SwiftUIMacros` compiler plugin required by `@State`.
   - **Rule:** Never use `@State` in any `.swift` file. Store mutable UI state as `@Published` properties on `DisplayManager.shared` (`@ObservedObject var manager = DisplayManager.shared`) or pass `Binding`s.
2. **Target & Minimum System Version (`26.0`):**
   - `Info.plist` **must** keep `<key>LSMinimumSystemVersion</key><string>26.0</string>` and `swiftc` **must** pass `-target arm64-apple-macosx26.0`.
   - Setting `LSMinimumSystemVersion` to `14.0` forces AppKit/SwiftUI into legacy Aqua slider compatibility mode and disables macOS 26+ Liquid Glass control metrics.

---

## 3. UI & Animation Patterns (Do Not Regress)

### A. Native Liquid Glass Slider Without Caret Cursor (`ArrowCursorNSSlider`)
- **Pitfall:** SwiftUI's `@available(macOS 26.0, *)` 9-parameter `Slider(value:in:neutralValue:label:currentValueLabel:...)` attaches an editable accessibility value region that switches the cursor to an I-beam caret (`NSCursor.iBeam`) when clicking the track.
- **Pattern:** Use `NativeLiquidGlassSlider` (`NSViewRepresentable` wrapping `ArrowCursorNSSlider: NSSlider`):
  - `slider.trackFillColor = .white` preserves Apple's real macOS 26 expanding refractive Liquid Glass thumb.
  - Override `resetCursorRects()`, `cursorUpdate(with:)`, and `mouseDown(with:)` to enforce `NSCursor.arrow.set()`.
  - Override `animation(forKey:) -> nil` so AppKit never stretches the `NSSlider`'s backing `CALayer` during layout transitions.
  - Place the unfilled track highlight `Capsule().fill(Color.white.opacity(0.18)).frame(height: 5).allowsHitTesting(false)` **behind** `NativeLiquidGlassSlider` in the `ZStack` so the native Liquid Glass thumb sits on top and receives all mouse events directly.

### B. Submenu Unroll Animation Without Rubber-Sheet Stretching
- **Pitfall:** Animating `.frame(height: isExpanded ? H : 0)` or `.padding(isExpanded ? 6 : 0)` directly on a `VStack` holding AppKit-backed views (`ScrollView` = `NSScrollView`, `NSSlider`) causes `NSHostingView` to interpolate the subviews' frames from `0 → H` with `kCAGravityResize`, stretching the rendered content like a rubber sheet.
- **Pattern (`CCExpandableSection` in `Components.swift`):**
  1. Keep horizontal width **100% constant** between collapsed and expanded states.
  2. Drive the `0 → H` layout height and `.clipped()` mask using a `Color.clear` window-shade spacer, and mount `bodyContent()` inside `.overlay(alignment: .top)` at a **fixed constant height** (`expandedBodyHeight + 34`) wrapped in **`.geometryGroup()`**:
     ```swift
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
     ```
  3. In `ZStack(alignment: .top)`, place the floating Liquid Glass header sheet (`.glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 10))`) with `.padding(2)` concentric inset at the top of the card, and give the scroll content `.padding(.top, 36)` so items scroll **underneath** the translucent glass header sheet.

### C. Dynamic Popover Sizing (`PopoverLayoutMetrics` & `AppDelegate.updatePopoverSize`)
- **Pitfall:** Letting `NSHostingController` resize an `NSPopover` window without updating `popover.contentSize` anchors AppKit's bottom-left `(0, 0)` origin and grows the top of the popover upward off the top of the screen. Conversely, shrinking `popover.contentSize` at `t = 0.0s` when collapsing a submenu clips the still-animating content.
- **Pattern:**
  - Compute all heights in `PopoverLayoutMetrics` (`MenuPopoverView.swift`), derived from `NSScreen.main?.visibleFrame.height` and `manager.displays.count`.
  - In `AppDelegate.updatePopoverSize(width:height:)`: grow `popover.contentSize` immediately on expand, and delay shrinking `popover.contentSize` by `0.22s` (matching `MenuPopoverView.slideSpring`) on collapse.

---

## 4. Display Hardware & Color Invariants

1. **Built-in Display Brightness Safety:**
   - Always read live system brightness via `DisplayServicesGetBrightness` inside `refreshDisplays()` for built-in displays.
   - **Never** call `DisplayServicesSetBrightness` inside `applyAdjustments` / `applyAllAdjustments` (startup, wake, or LUT drift timer). Only call `DisplayServicesSetBrightness` inside `setCombinedBrightness(_:)` when the user actively moves the Brightness slider.
2. **Hardware Bit-Depth Detection (`8-bit` vs. `10-bit`):**
   - SkyLight's `CGSDisplayModeDescription.bitsPerSample` reports `10` for the compositor framebuffer even on 8-bit monitors, and `IOMobileFramebufferShim.ColorElements` includes virtual 12-bit HDR elements (`IsVirtual = true`, `EOTF = 2`).
   - Always filter `IOMobileFramebufferShim`'s `ColorElements` for `IsVirtual == false && DynamicRange == 0 && EOTF == 0` (highest `Score` → `Depth`) to get the real physical link bit depth (`8-bit` on HP Z27u G3).
3. **Persistence & Display Identity:**
   - Key all saved settings (`adjustmentsByUUID`, `favoriteModeIDsByUUID`) by hardware Display UUID (`CGDisplayCreateUUIDFromDisplayID`), never by `CGDirectDisplayID` (which macOS reassigns across hotplugs).

---

## 5. Verification Checklist

After any UI or behavioral change:
1. Build and sign: `./build.sh` (must compile with 0 errors and 0 warnings).
2. Smoke CLI: `/Applications/DisplayControl.app/Contents/MacOS/DisplayControl --status`.
3. Visual window verification:
   - Launch with `open -a /Applications/DisplayControl.app --args --submenu <none|displayMode|imageAdjustments|textClarity|systemColors>`.
   - Query the onscreen window ID and bounds via `CGWindowListCopyWindowInfo` (verify `Y ≈ 25–30pt` below the menu bar and no top/bottom clipping).
   - Capture with `screencapture -x -l <windowID> /tmp/verify.png`, inspect visually, and delete temporary `/tmp/*.png` files before committing.
