# Codex Logo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a demo-only **Codex Logo** Experimental Shader screen with a reference-matching cloud/terminal mark and an orientation-reactive AI-brain gradient shader.

**Architecture:** The demo app owns the SwiftUI shape, controls, animation timing, drag fallback, and navigation entry. The Metal shader is added to the existing `Sources/ShaderKit/Shaders` package resource folder so it can be invoked from the demo through `ShaderKit.shaders` without adding a public `ShaderEffect` API.

**Tech Stack:** SwiftUI, Swift Testing, Metal stitchable SwiftUI layer effects, existing `ShaderKit.MotionManager`, existing demo app filesystem-synchronized Xcode project.

---

## File Structure

- Create `Sources/ShaderKit/Shaders/CodexLogoShader.metal`: package-bundled stitchable shader named `codexLogoBrain`.
- Create `Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift`: SwiftUI logo shape, terminal marks, shader invocation, motion/drag input, and compact controls.
- Modify `Demo/ShaderKitDemo/ShaderKitDemo/ContentView.swift`: add the `Codex Logo` Experimental Shaders navigation item.
- Modify `Demo/ShaderKitDemo/ShaderKitDemoTests/ShaderKitDemoTests.swift`: replace the starter test with focused tests for navigation metadata and deterministic motion/pulse math.

---

### Task 1: Failing Tests For Demo Contract

**Files:**
- Modify: `Demo/ShaderKitDemo/ShaderKitDemoTests/ShaderKitDemoTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
//
//  ShaderKitDemoTests.swift
//  ShaderKitDemoTests
//

import CoreGraphics
import Testing
@testable import ShaderKitDemo

@Suite("Codex Logo Demo")
struct CodexLogoDemoTests {

  @Test("Codex Logo appears as an experimental shader with reference identity")
  func codexLogoNavigationMetadataMatchesReferenceIdentity() {
    #expect(ShaderType.codexLogo.rawValue == "Codex Logo")
    #expect(ShaderType.codexLogo.section == .experimental)
    #expect(ShaderType.codexLogo.icon == "terminal.fill")
    #expect(ShaderType.codexLogo.description == "Pulsing AI-brain logo with orientation-reactive gradient light")
  }

  @Test("Codex Logo motion response clamps source tilt and applies strength")
  func codexLogoMotionResponseClampsTiltAndAppliesStrength() {
    let deviceTilt = CodexLogoMotionResponse.effectiveTilt(
      deviceTilt: CGPoint(x: 2.0, y: -3.0),
      dragTilt: CGPoint(x: -0.25, y: 0.25),
      motionStrength: 0.5,
      hasDeviceMotion: true
    )

    #expect(deviceTilt.x == 0.5)
    #expect(deviceTilt.y == -0.5)

    let dragTilt = CodexLogoMotionResponse.effectiveTilt(
      deviceTilt: .zero,
      dragTilt: CGPoint(x: -0.75, y: 0.25),
      motionStrength: 0.8,
      hasDeviceMotion: false
    )

    #expect(abs(dragTilt.x + 0.6) < 0.000001)
    #expect(abs(dragTilt.y - 0.2) < 0.000001)
  }

  @Test("Codex Logo reduced motion keeps the pulse subtle")
  func codexLogoReducedMotionKeepsPulseSubtle() {
    let animated = CodexLogoMotionResponse.pulseScale(
      time: 0.25,
      pulseSpeed: 1.0,
      reduceMotion: false
    )
    let reduced = CodexLogoMotionResponse.pulseScale(
      time: 0.25,
      pulseSpeed: 1.0,
      reduceMotion: true
    )

    #expect(abs(animated - 1.035) < 0.000001)
    #expect(abs(reduced - 1.006) < 0.000001)
  }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
xcodebuild test -project Demo/ShaderKitDemo/ShaderKitDemo.xcodeproj -scheme ShaderKitDemo -destination 'platform=iOS Simulator,name=iPhone 17'
```

Expected: FAIL because `ShaderType.codexLogo` and `CodexLogoMotionResponse` do not exist yet. If `iPhone 17` is unavailable locally, run `xcrun simctl list devices available` and repeat with an available iOS simulator destination.

---

### Task 2: Demo Navigation And Motion Math

**Files:**
- Create: `Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift`
- Modify: `Demo/ShaderKitDemo/ShaderKitDemo/ContentView.swift`
- Test: `Demo/ShaderKitDemo/ShaderKitDemoTests/ShaderKitDemoTests.swift`

- [ ] **Step 1: Add the Codex Logo navigation case**

In `ShaderType`, add the case after `liquidTech`:

```swift
case codexLogo = "Codex Logo"
```

Update the Experimental Shaders comment:

```swift
// Experimental Shaders (4 items)
```

Update `section`:

```swift
case .liquidTech, .codexLogo, .jellySwitch, .jellyButton:
  return .experimental
```

Update `description`:

```swift
case .codexLogo:
  return "Pulsing AI-brain logo with orientation-reactive gradient light"
```

Update `icon`:

```swift
case .codexLogo: return "terminal.fill"
```

Update `destination`:

```swift
case .codexLogo:
  CodexLogoView()
```

- [ ] **Step 2: Add the minimal demo view and deterministic helper**

Create `Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift`:

```swift
//
//  CodexLogoView.swift
//  ShaderKitDemo
//
//  Demo-only Codex Logo shader showcase
//

import SwiftUI
import ShaderKit

enum CodexLogoMotionResponse {
  static func effectiveTilt(
    deviceTilt: CGPoint,
    dragTilt: CGPoint,
    motionStrength: Double,
    hasDeviceMotion: Bool
  ) -> CGPoint {
    let source = hasDeviceMotion ? deviceTilt : dragTilt
    let strength = min(max(motionStrength, 0.0), 1.5)

    return CGPoint(
      x: min(max(source.x, -1.0), 1.0) * strength,
      y: min(max(source.y, -1.0), 1.0) * strength
    )
  }

  static func pulseScale(
    time: TimeInterval,
    pulseSpeed: Double,
    reduceMotion: Bool
  ) -> Double {
    let amplitude = reduceMotion ? 0.006 : 0.035
    let phase = sin(time * pulseSpeed * .pi * 2.0)
    return 1.0 + ((phase + 1.0) * 0.5 * amplitude)
  }
}

struct CodexLogoView: View {
  var body: some View {
    Text("Codex Logo")
      .navigationTitle("Codex Logo")
  }
}

#Preview {
  NavigationStack {
    CodexLogoView()
  }
}
```

- [ ] **Step 3: Run tests to verify they pass**

Run:

```bash
xcodebuild test -project Demo/ShaderKitDemo/ShaderKitDemo.xcodeproj -scheme ShaderKitDemo -destination 'platform=iOS Simulator,name=iPhone 17'
```

Expected: PASS for the `Codex Logo Demo` tests.

- [ ] **Step 4: Commit**

```bash
git add Demo/ShaderKitDemo/ShaderKitDemo/ContentView.swift Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift Demo/ShaderKitDemo/ShaderKitDemoTests/ShaderKitDemoTests.swift
git commit -m "Add Codex Logo demo contract"
```

---

### Task 3: Codex Logo Shader

**Files:**
- Create: `Sources/ShaderKit/Shaders/CodexLogoShader.metal`
- Modify: `Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift`

- [ ] **Step 1: Add the Metal shader**

Create `Sources/ShaderKit/Shaders/CodexLogoShader.metal`:

```metal
//
//  CodexLogoShader.metal
//  ShaderKit
//
//  Demo-only Codex Logo neural gradient shader
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

static float codexSaturate(float value) {
  return clamp(value, 0.0, 1.0);
}

static float3 codexMix(float3 a, float3 b, float value) {
  return a + (b - a) * value;
}

[[stitchable]] half4 codexLogoBrain(
  float2 position,
  SwiftUI::Layer layer,
  float2 size,
  float2 tilt,
  float time,
  float intensity,
  float pulseSpeed,
  float neuralDensity,
  float glow,
  float motionResponse
) {
  half4 sampled = layer.sample(position);
  float alpha = float(sampled.a);

  if (alpha <= 0.001) {
    return sampled;
  }

  float2 safeSize = max(size, float2(1.0));
  float2 uv = position / safeSize;
  float2 centered = (uv - 0.5) * 2.0;
  centered.x *= safeSize.x / safeSize.y;

  float2 reactiveTilt = tilt * motionResponse;
  float t = time * max(pulseSpeed, 0.05);
  float radial = length(centered);
  float angle = atan2(centered.y, centered.x);
  float pulse = 0.5 + 0.5 * sin(t * 4.2 - radial * 3.0);

  float density = max(neuralDensity, 0.1);
  float waveA = sin((centered.x + reactiveTilt.x * 0.28) * 10.0 * density + t * 2.4);
  float waveB = sin((centered.y - reactiveTilt.y * 0.25) * 13.0 * density - t * 2.0);
  float waveC = sin(angle * 5.0 + radial * 18.0 * density - t * 1.7);
  float interference = (waveA + waveB + waveC) / 3.0;
  float neural = pow(codexSaturate(abs(interference)), 2.4);

  float thread = smoothstep(0.50, 0.95, neural);
  float synapse = pow(codexSaturate(sin((radial * 24.0 - t * 3.1) + angle * 3.0)), 14.0);

  float3 blue = float3(0.14, 0.33, 1.0);
  float3 periwinkle = float3(0.45, 0.60, 1.0);
  float3 violet = float3(0.42, 0.24, 1.0);
  float3 cyan = float3(0.28, 0.95, 1.0);
  float3 magenta = float3(0.92, 0.36, 1.0);
  float3 warmWhite = float3(1.0, 0.92, 0.72);

  float gradientPhase = codexSaturate(uv.y * 0.72 + uv.x * 0.28 + reactiveTilt.y * 0.18);
  float3 base = codexMix(blue, periwinkle, smoothstep(0.0, 0.75, gradientPhase));
  base = codexMix(base, violet, smoothstep(0.45, 1.0, uv.y + reactiveTilt.x * 0.12));

  float2 lightAnchor = float2(0.58, 0.30) + reactiveTilt * 0.24;
  float lightDistance = distance(uv, lightAnchor);
  float specular = exp(-lightDistance * 7.0) * (0.65 + pulse * 0.35);

  float2 bandDirection = normalize(float2(0.70 + reactiveTilt.x, -0.42 + reactiveTilt.y));
  float band = 1.0 - abs(dot(centered, bandDirection) - sin(t * 0.72) * 0.38);
  band = pow(codexSaturate(band), 8.0);

  float3 neuralColor = codexMix(cyan, magenta, 0.5 + 0.5 * sin(angle * 2.0 + t));
  float3 color = base;
  color += neuralColor * thread * 0.30 * intensity;
  color += cyan * synapse * 0.22 * intensity;
  color += warmWhite * specular * 0.38 * glow;
  color += warmWhite * band * 0.24 * glow;
  color *= 0.88 + 0.20 * pulse * intensity;

  color = min(color, float3(1.0));
  return half4(half3(color), half(alpha));
}
```

- [ ] **Step 2: Verify the package shader resources build**

Run:

```bash
swift build
```

Expected: PASS, including Metal shader compilation for the `ShaderKit` target.

---

### Task 4: Full Animated SwiftUI Demo

**Files:**
- Modify: `Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift`

- [ ] **Step 1: Replace the initial view with the complete demo**

Replace `CodexLogoView.swift` with:

```swift
//
//  CodexLogoView.swift
//  ShaderKitDemo
//
//  Demo-only Codex Logo shader showcase
//

import SwiftUI
import ShaderKit

enum CodexLogoMotionResponse {
  static func effectiveTilt(
    deviceTilt: CGPoint,
    dragTilt: CGPoint,
    motionStrength: Double,
    hasDeviceMotion: Bool
  ) -> CGPoint {
    let source = hasDeviceMotion ? deviceTilt : dragTilt
    let strength = min(max(motionStrength, 0.0), 1.5)

    return CGPoint(
      x: min(max(source.x, -1.0), 1.0) * strength,
      y: min(max(source.y, -1.0), 1.0) * strength
    )
  }

  static func pulseScale(
    time: TimeInterval,
    pulseSpeed: Double,
    reduceMotion: Bool
  ) -> Double {
    let amplitude = reduceMotion ? 0.006 : 0.035
    let phase = sin(time * pulseSpeed * .pi * 2.0)
    return 1.0 + ((phase + 1.0) * 0.5 * amplitude)
  }
}

struct CodexLogoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var motionManager = MotionManager()
  @State private var dragTilt = CGPoint.zero
  @State private var intensity = 0.92
  @State private var pulse = 0.72
  @State private var density = 1.0
  @State private var glow = 0.88
  @State private var motion = 0.82

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.02, green: 0.025, blue: 0.04),
          Color(red: 0.06, green: 0.07, blue: 0.11),
          Color(red: 0.02, green: 0.03, blue: 0.06)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 22) {
        TimelineView(.animation) { context in
          let time = context.date.timeIntervalSinceReferenceDate
          let tilt = CodexLogoMotionResponse.effectiveTilt(
            deviceTilt: motionManager.tilt,
            dragTilt: dragTilt,
            motionStrength: motion,
            hasDeviceMotion: motionManager.isAvailable
          )
          let scale = CodexLogoMotionResponse.pulseScale(
            time: time,
            pulseSpeed: pulse,
            reduceMotion: reduceMotion
          )

          CodexLogoMark(
            time: time,
            tilt: tilt,
            scale: scale,
            intensity: intensity,
            pulse: pulse,
            density: density,
            glow: glow,
            motion: motion,
            reduceMotion: reduceMotion,
            dragTilt: $dragTilt
          )
          .frame(maxWidth: 340)
          .aspectRatio(1.08, contentMode: .fit)
          .padding(.horizontal, 26)
        }

        controls
      }
      .padding(.vertical, 20)
    }
    .navigationTitle("Codex Logo")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
    .onAppear {
      motionManager.start()
    }
    .onDisappear {
      motionManager.stop()
    }
  }

  private var controls: some View {
    ScrollView {
      VStack(spacing: 12) {
        CodexLogoSliderRow(title: "intensity", value: $intensity, range: 0...1.25)
        CodexLogoSliderRow(title: "pulse", value: $pulse, range: 0.2...1.6)
        CodexLogoSliderRow(title: "density", value: $density, range: 0.4...1.8)
        CodexLogoSliderRow(title: "glow", value: $glow, range: 0...1.4)
        CodexLogoSliderRow(title: "motion", value: $motion, range: 0...1.2)
      }
      .padding(16)
      .background(Color.white.opacity(0.08))
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .overlay {
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.white.opacity(0.10), lineWidth: 1)
      }
      .padding(.horizontal, 16)
    }
    .frame(maxHeight: 240)
  }
}

private struct CodexLogoMark: View {
  let time: TimeInterval
  let tilt: CGPoint
  let scale: Double
  let intensity: Double
  let pulse: Double
  let density: Double
  let glow: Double
  let motion: Double
  let reduceMotion: Bool
  @Binding var dragTilt: CGPoint

  var body: some View {
    GeometryReader { proxy in
      let size = proxy.size
      let shortestSide = min(size.width, size.height)
      let glowRadius = reduceMotion ? 16.0 : 30.0 + glow * 10.0

      ZStack {
        CodexLogoBlobShape()
          .fill(Color(red: 0.24, green: 0.36, blue: 1.0))
          .blur(radius: glowRadius)
          .opacity(0.42 + glow * 0.18)
          .scaleEffect(1.02)

        CodexLogoBlobShape()
          .fill(.white)
          .layerEffect(
            ShaderKit.shaders.codexLogoBrain(
              .float2(size.width, size.height),
              .float2(tilt.x, tilt.y),
              .float(time),
              .float(intensity),
              .float(pulse),
              .float(density),
              .float(glow),
              .float(motion)
            ),
            maxSampleOffset: .zero
          )
          .shadow(color: Color(red: 0.27, green: 0.42, blue: 1.0).opacity(0.65), radius: 22, y: 12)
          .overlay {
            CodexLogoBlobShape()
              .stroke(
                LinearGradient(
                  colors: [
                    .white.opacity(0.52),
                    .white.opacity(0.08),
                    Color(red: 0.55, green: 0.72, blue: 1.0).opacity(0.34)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: max(1.0, shortestSide * 0.012)
              )
          }

        CodexLogoTerminalMarks()
          .stroke(
            .white,
            style: StrokeStyle(
              lineWidth: shortestSide * 0.085,
              lineCap: .round,
              lineJoin: .round
            )
          )
          .shadow(color: .white.opacity(0.45), radius: 8)
      }
      .scaleEffect(scale)
      .rotation3DEffect(
        .degrees(tilt.y * -7.0),
        axis: (x: 1.0, y: 0.0, z: 0.0),
        perspective: 0.55
      )
      .rotation3DEffect(
        .degrees(tilt.x * 7.0),
        axis: (x: 0.0, y: 1.0, z: 0.0),
        perspective: 0.55
      )
      .contentShape(Rectangle())
      .gesture(dragGesture(in: size))
    }
  }

  private func dragGesture(in size: CGSize) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        dragTilt = CGPoint(
          x: min(max((value.location.x / max(size.width, 1.0) - 0.5) * 2.0, -1.0), 1.0),
          y: min(max((value.location.y / max(size.height, 1.0) - 0.5) * 2.0, -1.0), 1.0)
        )
      }
      .onEnded { _ in
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
          dragTilt = .zero
        }
      }
  }
}

private struct CodexLogoBlobShape: Shape {
  func path(in rect: CGRect) -> Path {
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
      CGPoint(
        x: rect.minX + rect.width * x,
        y: rect.minY + rect.height * y
      )
    }

    var path = Path()
    path.move(to: point(0.19, 0.57))
    path.addCurve(to: point(0.25, 0.29), control1: point(0.08, 0.53), control2: point(0.09, 0.34))
    path.addCurve(to: point(0.55, 0.11), control1: point(0.30, 0.14), control2: point(0.43, 0.06))
    path.addCurve(to: point(0.69, 0.17), control1: point(0.61, 0.11), control2: point(0.65, 0.13))
    path.addCurve(to: point(0.90, 0.39), control1: point(0.82, 0.12), control2: point(0.94, 0.23))
    path.addCurve(to: point(0.89, 0.57), control1: point(0.98, 0.45), control2: point(0.96, 0.55))
    path.addCurve(to: point(0.75, 0.84), control1: point(0.98, 0.72), control2: point(0.91, 0.86))
    path.addCurve(to: point(0.40, 0.86), control1: point(0.66, 0.99), control2: point(0.48, 0.98))
    path.addCurve(to: point(0.21, 0.76), control1: point(0.31, 0.89), control2: point(0.22, 0.84))
    path.addCurve(to: point(0.19, 0.57), control1: point(0.11, 0.75), control2: point(0.10, 0.62))
    path.closeSubpath()
    return path
  }
}

private struct CodexLogoTerminalMarks: Shape {
  func path(in rect: CGRect) -> Path {
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
      CGPoint(
        x: rect.minX + rect.width * x,
        y: rect.minY + rect.height * y
      )
    }

    var path = Path()
    path.move(to: point(0.35, 0.39))
    path.addLine(to: point(0.47, 0.56))
    path.addLine(to: point(0.35, 0.73))
    path.move(to: point(0.60, 0.65))
    path.addLine(to: point(0.78, 0.65))
    return path
  }
}

private struct CodexLogoSliderRow: View {
  let title: String
  @Binding var value: Double
  let range: ClosedRange<Double>

  var body: some View {
    HStack(spacing: 12) {
      Text(title)
        .font(.subheadline)
        .frame(width: 78, alignment: .leading)
      Slider(value: $value, in: range)
      Text(String(format: "%.2f", value))
        .font(.subheadline.monospacedDigit())
        .frame(width: 52, alignment: .trailing)
    }
    .foregroundStyle(.white.opacity(0.92))
  }
}

#Preview {
  NavigationStack {
    CodexLogoView()
  }
}
```

- [ ] **Step 2: Run tests and build**

Run:

```bash
xcodebuild test -project Demo/ShaderKitDemo/ShaderKitDemo.xcodeproj -scheme ShaderKitDemo -destination 'platform=iOS Simulator,name=iPhone 17'
```

Expected: PASS.

Run:

```bash
swift build
```

Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add Sources/ShaderKit/Shaders/CodexLogoShader.metal Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift
git commit -m "Add animated Codex Logo shader demo"
```

---

### Task 5: Final Verification

**Files:**
- Verify: `Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift`
- Verify: `Sources/ShaderKit/Shaders/CodexLogoShader.metal`
- Verify: `Demo/ShaderKitDemo/ShaderKitDemo/ContentView.swift`

- [ ] **Step 1: Run repository status**

Run:

```bash
git status --short
```

Expected: only pre-existing unrelated untracked files may remain, specifically `Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/GlassOrbView.swift`.

- [ ] **Step 2: Run final build verification**

Run:

```bash
swift build
```

Expected: PASS.

Run:

```bash
xcodebuild test -project Demo/ShaderKitDemo/ShaderKitDemo.xcodeproj -scheme ShaderKitDemo -destination 'platform=iOS Simulator,name=iPhone 17'
```

Expected: PASS. If the exact simulator is unavailable, use an installed iOS simulator and record the destination.
