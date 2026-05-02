# Codex Logo Demo Design

## Goal

Build a demo-only SwiftUI/Metal showcase named **Codex Logo**. The demo should recreate the supplied logo's identity: a rounded cloud-like blob silhouette, white terminal chevron and underscore marks, and a luminous blue-to-violet gradient. The animation should feel like an artificial intelligence brain: alive, pulsing, reactive, and filled with moving internal light.

## Scope

This first version belongs only to the demo app under Experimental Shaders. It should not add public `ShaderKit` API yet. The shader and SwiftUI view should be structured so the effect can later move into the library with minimal reshaping.

## Visual Direction

The logo body will be drawn as a vector SwiftUI shape approximating the reference image's scalloped cloud outline. The terminal marks will be white overlays cut visually into the body with a bold chevron and underscore. The base palette will preserve the reference: saturated electric blue through periwinkle and violet, with cyan, magenta, and white-gold shader highlights used as transient light rather than replacing the core identity.

The motion should combine three layers:

- A slow breathing scale pulse across the entire logo.
- Internal neural wave fields that rotate and interfere inside the logo mask.
- Orientation-driven shine, where the highlight vector, color phase, and subtle light bands respond to device motion or drag.

## Architecture

Add a new demo screen at `Demo/ShaderKitDemo/ShaderKitDemo/Views/ExperimentalShaders/CodexLogoView.swift`. Add the shader at `Sources/ShaderKit/Shaders/CodexLogoShader.metal` so it is bundled through the existing Swift package shader resource pipeline. Do not add a public `ShaderEffect` case or view extension in this phase; the demo will call the shader through `ShaderKit.shaders`.

The SwiftUI view will own:

- Time animation driven by `TimelineView(.animation)`.
- Motion input from `MotionManager`.
- Drag fallback for simulator and macOS.
- Tunable state for intensity, pulse speed, neural density, glow, and orientation response.

The Metal shader will own:

- A gradient field anchored to normalized logo coordinates.
- Tilt-biased light direction math.
- Procedural neural waves using radial distance, angular phase, and interference.
- Specular shine and bloom-like color lift inside the logo body.

## Data Flow

`CodexLogoView` computes elapsed time and normalized tilt, then passes size, tilt, time, intensity, pulse speed, neural density, glow, and motion response into the shader. SwiftUI draws the logo silhouette and terminal glyphs; Metal modifies only the logo body pixels so the marks remain crisp white.

## Controls

The demo should include a compact control panel matching existing experimental shader demos. Controls:

- `intensity`: shader color and light strength.
- `pulse`: breathing and neural pulse speed.
- `density`: internal wave/brain detail.
- `glow`: outer and inner luminance.
- `motion`: how strongly orientation affects shine.

## Accessibility

Respect Reduce Motion by lowering pulse amplitude, reducing continuous shimmer, and keeping the logo readable. The static identity must remain recognizable even when motion is reduced.

## Testing

Build the demo target or package as far as the local project allows. Verify the new navigation entry appears under Experimental Shaders, the SwiftUI view compiles, and shader function signatures match their Swift invocation.
