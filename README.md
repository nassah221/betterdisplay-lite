# DisplayControl (BetterDisplayLite)

Native macOS 26+ menu bar display & image adjustment controller built in pure Swift (`AppKit` + `SwiftUI`, zero external dependencies).

## Features

- **Per-Display Resolution & HiDPI Control**:
  - Instant mode switching via CoreGraphics (`CGDisplayCopyAllDisplayModes` / `CGConfigureDisplayWithDisplayMode`).
  - Favorite / pinned display modes (`[★ Manage…]`) persisted per display UUID.
  - 1-click **Flexible HiDPI Scaling Override** generator (`/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-<vid>/DisplayProductID-<pid>`) unlocking 16px-step 2× Retina HiDPI resolutions on external 1440p/4K monitors.
  - Dynamic hardware link bit-depth detection (`8-bit` / `10-bit`) via `IOMobileFramebufferShim` (`ColorElements`) and SkyLight `CGSGetDisplayModeDescriptionOfLength`.
- **Image Adjustments**:
  - **Hardware Color Table (`🎨` 0% GPU via `CGSetDisplayTransferByTable`)**: Contrast, Gamma, Gain, Highlight, Shadow, Color Temperature, Quantization, and per-channel RGB Gamma & Gain.
  - **Compositor Filter Layer (`CABackdropLayer` + `CAFilter`)**: Saturation, Vibrance, Hue, Sepia (excluded from screenshots via `window.sharingType = .none`).
  - **Combined Brightness**: Native backlight (`DisplayServicesSetBrightness` on built-in displays; `IOAVServiceWriteI2C` DDC/CI `VCP 0x10` on external monitors) + software LUT dimming.
- **Text Clarity & System Colors**:
  - macOS Font Smoothing (`AppleFontSmoothing`) selector + DDC hardware sharpness (`VCP 0x87`).
  - Dark Mode (`SLSSetAppearanceThemeLegacy`), True Tone (`CBAdaptationClient`), and Night Shift + Intensity (`CBBlueLightClient`).
- **Safety & Persistence**:
  - Global panic reset shortcut (`⌘⌥⇧R`) restores factory ColorSync LUTs and removes compositor overlays.
  - Per-display UUID persistence in `UserDefaults` + Launch at Login (`~/Library/LaunchAgents/com.local.DisplayControl.plist`).

## Build & Install

```bash
./build.sh
open -a /Applications/DisplayControl.app
```

## CLI Usage

```bash
/Applications/DisplayControl.app/Contents/MacOS/DisplayControl --status
/Applications/DisplayControl.app/Contents/MacOS/DisplayControl --set-brightness external 80
/Applications/DisplayControl.app/Contents/MacOS/DisplayControl --set-mode external 2336 1314 hidpi
/Applications/DisplayControl.app/Contents/MacOS/DisplayControl --toggle-favorite builtin 1920 1243 hidpi
/Applications/DisplayControl.app/Contents/MacOS/DisplayControl --reset
```
