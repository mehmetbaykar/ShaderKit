//
//  ShaderKitTests.swift
//  ShaderKit
//
//  Tests for ShaderKit package
//

import Testing
@testable import ShaderKit

@Suite("ShaderKit Tests")
struct ShaderKitTests {

    @Test("Version is set")
    func versionIsSet() {
        #expect(ShaderKit.version == "1.0.0")
    }

}
