//
//  CodexGradientFoilView.swift
//  ShaderKitDemo
//
//  Codex artwork card using the Gradient Foil composition
//

import SwiftUI
import ShaderKit

private enum CodexGradientPalette {
  static let light = Color(red: 177.0 / 255.0, green: 167.0 / 255.0, blue: 255.0 / 255.0)
  static let mid = Color(red: 122.0 / 255.0, green: 157.0 / 255.0, blue: 255.0 / 255.0)
  static let deep = Color(red: 57.0 / 255.0, green: 65.0 / 255.0, blue: 255.0 / 255.0)

  static let colors = [light, mid, deep]
}

struct CodexGradientFoilView: View {
  var body: some View {
    HolographicCardContainer(
      width: 280,
      height: 400,
      cornerRadius: 20,
      shadowColor: CodexGradientPalette.mid
    ) {
      CodexGradientFoilContent()
        .foil()
        .glitter()
        .lightSweep()
    }
  }
}

// MARK: - Card Content

private struct CodexGradientFoilContent: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .fill(
          LinearGradient(
            colors: CodexGradientPalette.colors,
            startPoint: .top,
            endPoint: .bottom
          )
        )

      // Artwork - full bleed background
      Image("codex")
        .renderingMode(.original)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 280, height: 400)
        .clipped()

      VStack(spacing: 12) {
        HStack {
          Text("Gradient Foil")
            .font(.headline)
            .fontWeight(.heavy)
            .foregroundStyle(.white)
          Spacer()
          Text("LV 200")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(CodexGradientPalette.light)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)

        Spacer()

        VStack(spacing: 8) {
          HStack {
            Image(systemName: "paintpalette.fill")
              .foregroundStyle(CodexGradientPalette.light)
            Text("Rainbow Gradient")
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundStyle(.white)
            Spacer()
            Text("150")
              .font(.title3)
              .fontWeight(.black)
              .foregroundStyle(CodexGradientPalette.light)
          }

          Text("Multi-Color Holographic Effect")
            .font(.caption2)
            .foregroundStyle(CodexGradientPalette.light.opacity(0.85))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
      }

      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(
          LinearGradient(
            colors: CodexGradientPalette.colors,
            startPoint: .top,
            endPoint: .bottom
          ),
          lineWidth: 3
        )
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    CodexGradientFoilView()
  }
}
