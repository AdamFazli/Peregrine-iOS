//
//  UIColorExtensionTests.swift
//  StockScreenerAppTests
//
//  Created on 2/11/26.
//

import XCTest
@testable import StockScreenerApp

final class UIColorExtensionTests: XCTestCase {
    
    func testHexColorInitialization() {
        let greenColor = UIColor(hex: "#13ec80")
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        greenColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(Int(red * 255), 19, accuracy: 1)
        XCTAssertEqual(Int(green * 255), 236, accuracy: 1)
        XCTAssertEqual(Int(blue * 255), 128, accuracy: 1)
        XCTAssertEqual(alpha, 1.0)
    }
    
    func testHexColorWithoutHash() {
        let color1 = UIColor(hex: "#ff0000")
        let color2 = UIColor(hex: "ff0000")
        
        XCTAssertTrue(areColorsEqual(color1, color2))
    }
    
    func testInvalidHexReturnsBlack() {
        let invalidColor = UIColor(hex: "invalid")
        
        XCTAssertTrue(isColorBlack(invalidColor), "Invalid hex should return black")
    }
    
    func testShortHexFormat() {
        let color = UIColor(hex: "#000")
        
        XCTAssertTrue(isColorBlack(color), "Short hex #000 should return black")
    }
    
    private func isColorBlack(_ color: UIColor) -> Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return abs(red) < 0.01 && abs(green) < 0.01 && abs(blue) < 0.01 && abs(alpha - 1.0) < 0.01
    }
    
    private func areColorsEqual(_ color1: UIColor, _ color2: UIColor) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return abs(r1 - r2) < 0.01 && abs(g1 - g2) < 0.01 && abs(b1 - b2) < 0.01 && abs(a1 - a2) < 0.01
    }
}
