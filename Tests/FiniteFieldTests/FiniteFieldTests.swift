//
//  FiniteFieldTests.swift
//  FiniteFieldTests
//

import XCTest
import FiniteField

struct FF_31: FiniteFieldInteger {
	static var Order = UInt8(31)
	var value: Element = 0
}

struct FF_37: FiniteFieldInteger {
	static var Order = UInt8(37)
	var value: Element = 0
}

struct FF_251: FiniteFieldInteger {
	static var Order = UInt8(251)
	var value: Element = 0
}

final class FiniteFieldTests: XCTestCase {
	func testInitIntegerLiteral() {
		let ff1: FF_31 = 5
		XCTAssertEqual(ff1.value, 5)
		let ff2: FF_31 = 37
		XCTAssertEqual(ff2.value, 6)
	}
	
	func testInitBinaryIntegerExactly() {
		let ff1 = FF_31(exactly: Int(21))
		XCTAssertEqual(ff1?.value ?? 0, 21)
		let ff2 = FF_31(exactly: Int(32))
		XCTAssertNil(ff2)
	}
	
	func testInitFloatingPointExactly() {
		let ff1 = FF_31(exactly: Double(12.0))
		XCTAssertEqual(ff1?.value ?? 0, 12)
		let ff2 = FF_31(exactly: Double(50.0))
		XCTAssertNil(ff2)
		let ff3 = FF_31(exactly: Double(12.1))
		XCTAssertNil(ff3)
	}
	
	func testInitBinaryInteger() {
		let ff1 = FF_31(Int(4))
		XCTAssertEqual(ff1.value, 4)
		let ff2 = FF_31(Int(34))
		XCTAssertEqual(ff2.value, 3)
		let ff3 = FF_31(Int(-34))
		XCTAssertEqual(ff3.value, 28)
	}
	
	func testInitFloatingPoint() {
		let ff1 = FF_31(Double(4.2))
		XCTAssertEqual(ff1.value, 4)
		let ff2 = FF_31(Double(44.2))
		XCTAssertEqual(ff2.value, 13)
		let ff3 = FF_31(Double(-4.8))
		XCTAssertEqual(ff3.value, 27)
	}
	
	func testInitBinaryIntegerClamping() {
		let ff1 = FF_31(clamping: Int(9))
		XCTAssertEqual(ff1.value, 9)
		let ff2 = FF_31(clamping: Int(50))
		XCTAssertEqual(ff2.value, 30)
		let ff3 = FF_31(clamping: Int(-50))
		XCTAssertEqual(ff3.value, 0)
	}
	
	func testInitBinaryIntegerTruncatingIfNeeded() {
		let ff1 = FF_31(truncatingIfNeeded: Int(9))
		XCTAssertEqual(ff1.value, 9)
		let ff2 = FF_31(truncatingIfNeeded: Int(46367))
		XCTAssertEqual(ff2.value, 15)
		let ff3 = FF_31(truncatingIfNeeded: Int(-46367))
		XCTAssertEqual(ff3.value, 1)
	}
	
	func testInitString() {
		let ff1 = FF_31("29")
		XCTAssertEqual(ff1?.value ?? 0, 29)
		let ff2 = FF_31("50")
		XCTAssertNil(ff2)
		let ff3 = FF_31("-1")
		XCTAssertNil(ff3)
	}
	
	func testAddition() {
		var ff: FF_31 = 6
		ff = ff + 10
		XCTAssertEqual(ff.value, 16)
		ff += 20
		XCTAssertEqual(ff.value, 5)
	}
	
	func testSubtraction() {
		var ff: FF_31 = 6
		ff = ff - 10
		XCTAssertEqual(ff.value, 27)
		ff -= 20
		XCTAssertEqual(ff.value, 7)
	}
	
	func testMultiplication() {
		var ff: FF_31 = 8
		ff = ff * 3
		XCTAssertEqual(ff.value, 24)
		ff *= 3
		XCTAssertEqual(ff.value, 10)
	}
	
	func testDivision() {
		var ff: FF_31 = 21
		ff = ff / 3
		XCTAssertEqual(ff.value, 7)
		ff /= 3
		XCTAssertEqual(ff.value, 23)
	}
	
	func testRemainder() {
		var ff: FF_31 = 30
		ff = ff % 11
		XCTAssertEqual(ff.value, 8)
		ff %= 3
		XCTAssertEqual(ff.value, 2)
	}
	
	func testAnd() {
		var ff: FF_37 = 23
		ff = ff & 29
		XCTAssertEqual(ff.value, 21)
		ff &= 12
		XCTAssertEqual(ff.value, 4)
	}
	
	func testOr() {
		var ff: FF_37 = 16
		ff = ff | 8
		XCTAssertEqual(ff.value, 24)
		ff |= 32
		XCTAssertEqual(ff.value, 36)
	}
	
	func testXor() {
		var ff: FF_37 = 26
		ff = ff ^ 35
		XCTAssertEqual(ff.value, 36)
		ff ^= 6
		XCTAssertEqual(ff.value, 34)
	}
	
	func testNot() {
		var ff: FF_251 = 213
		ff = ~ff
		XCTAssertEqual(ff.value, 42)
		ff = 2
		ff = ~ff
		XCTAssertEqual(ff.value, 250)
	}
	
	func testRightShift() {
		var ff: FF_37 = 36
		ff = ff >> 2
		XCTAssertEqual(ff.value, 9)
		ff >>= 5
		XCTAssertEqual(ff.value, 0)
	}
	
	func testLeftShift() {
		var ff: FF_37 = 8
		ff = ff << 2
		XCTAssertEqual(ff.value, 32)
		ff <<= 1
		XCTAssertEqual(ff.value, 36)
		ff <<= 8
		XCTAssertEqual(ff.value, 0)
	}
	
	func testExponentiation() {
		let ff: FF_31 = 5
		XCTAssertEqual(ff.exponentiating(by: 2).value, 25)
		XCTAssertEqual(ff.exponentiating(by: 9).value, 1)
	}
	
	func testRandom() {
		let range1: Range<FF_31> = 4..<6
		let range2: ClosedRange<FF_31> = 4...6
		for _ in 0..<10 {
			XCTAssertTrue(range1.contains(FF_31.random(in: range1)))
			XCTAssertTrue(range2.contains(FF_31.random(in: range2)))
		}
		XCTAssertTrue((0..<1000).map{_ in FF_31.random(in: range2)}.contains(6))
	}
	
	func testEquality() {
		XCTAssertEqual(FF_31(5), FF_31(5))
		XCTAssertNotEqual(FF_31(5), FF_31(10))
	}
	
	func testComparison() {
		XCTAssertLessThan(FF_31(4), FF_31(5))
		XCTAssertGreaterThan(FF_31(10), FF_31(1))
	}
	
	func testHashing() {
		var hasher1 = Hasher()
		var hasher2 = Hasher()
		let ff = FF_31(10)
		ff.hash(into: &hasher1)
		ff.value.hash(into: &hasher2)
		XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
	}
	
	func testStride() {
		XCTAssertEqual(Array(stride(from: FF_31(4), to: FF_31(6), by: 1)), [4, 5])
	}
}
