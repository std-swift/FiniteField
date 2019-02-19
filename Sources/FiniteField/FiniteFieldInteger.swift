//
//  FiniteFieldInteger.swift
//  FiniteField
//

import ModularArithmetic

/// A protocol used to define finite fields containing `Order` integers starting
/// from zero
///
/// To create a finite field, simply pick a prime and an appropriate
/// `FixedWidthInteger & UnsignedInteger`. e.g. A 31 element `UInt8` field:
///
///     struct F_31: FiniteFieldInteger {
///         static var Order = UInt8(31)
///         var value: Element = 0
///     }
///
/// - Note: `Self.Order` must be prime for division
public protocol FiniteFieldInteger: UnsignedInteger, LosslessStringConvertible {
	associatedtype Element: UnsignedInteger, LosslessStringConvertible, ModularOperations
	
	static var Order: Element { get }
	
	var value: Element { get set }
	
	init()
}

/// Properties
extension FiniteFieldInteger {
	@inlinable
	public var words: Element.Words {
		return self.value.words
	}
	
	@inlinable
	public var bitWidth: Int {
		return self.value.bitWidth
	}
	
	@inlinable
	public var trailingZeroBitCount: Int {
		return self.value.trailingZeroBitCount
	}
}

/// Initializers
extension FiniteFieldInteger {
	@inlinable
	public init(integerLiteral value: Element.IntegerLiteralType) {
		self.init()
		self.value = Element(integerLiteral: value).modulo(Self.Order)
	}
	
	@inlinable
	public init?<T: BinaryInteger>(exactly source: T) {
		self.init()
		guard let value = Element(exactly: source) else { return nil }
		guard value >= 0 && value < Self.Order else { return nil }
		self.value = value
	}
	
	@inlinable
	public init?<T: BinaryFloatingPoint>(exactly source: T) {
		self.init()
		guard let value = Element(exactly: source) else { return nil }
		guard value >= 0 && value < Self.Order else { return nil }
		self.value = value
	}
	
	@inlinable
	public init<T: BinaryInteger>(_ source: T) {
		self.init()
		if let exact = Element(exactly: source) {
			self.value = exact.modulo(Self.Order)
		} else {
			guard let order = T(exactly: Self.Order) else { fatalError() }
			self.value = Element(source.modulo(order))
		}
	}
	
	@inlinable
	public init<T: BinaryFloatingPoint>(_ source: T) {
		self.init()
		let source = source.rounded(.towardZero)
		if let exact = Element(exactly: source) {
			self.value = exact.modulo(Self.Order)
		} else {
			guard let order = T(exactly: Self.Order) else { fatalError() }
			let remainder = source.remainder(dividingBy: order)
			self.value = Element(remainder >= 0 ? remainder : remainder + order)
		}
	}
	
	@inlinable
	public init<T: BinaryInteger>(clamping source: T) {
		self.init()
		self.value = Element(clamping: source)
		if self.value < 0 { self.value = 0 }
		else if self.value >= Self.Order { self.value = Self.Order - 1 }
	}
	
	@inlinable
	public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
		self.init()
		self.value = Element(truncatingIfNeeded: source)
		if self.value < 0 || self.value >= Self.Order {
			var bit = ~Element(1 << (self.value.bitWidth - 1))
			while self.value < 0 || self.value >= Self.Order {
				self.value &= bit
				bit >>= 1
			}
		}
	}
	
	@inlinable
	public init?(_ description: String) {
		self.init()
		guard let value = Element(description) else { return nil }
		guard value >= 0 && value < Self.Order else { return nil }
		self.value = value
	}
}

/// Operators
extension FiniteFieldInteger {
	@inlinable
	public static func + (lhs: Self, rhs: Self) -> Self {
		var lhs = lhs
		lhs += rhs
		return lhs
	}
	
	@inlinable
	public static func - (lhs: Self, rhs: Self) -> Self {
		var lhs = lhs
		lhs -= rhs
		return lhs
	}
	
	@inlinable
	public static func * (lhs: Self, rhs: Self) -> Self {
		var lhs = lhs
		lhs *= rhs
		return lhs
	}
	
	@inlinable
	public static func / (lhs: Self, rhs: Self) -> Self {
		var lhs = lhs
		lhs /= rhs
		return lhs
	}
	
	@inlinable
	public static func % (lhs: Self, rhs: Self) -> Self {
		var lhs = lhs
		lhs %= rhs
		return lhs
	}
	
	@inlinable
	public static prefix func ~ (x: Self) -> Self {
		return Self(clamping: ~x.value)
	}
}

/// Assignment Operators
extension FiniteFieldInteger {
	@inlinable
	public static func += (lhs: inout Self, rhs: Self) {
		lhs.value = lhs.value.adding(rhs.value, modulo: Self.Order)
	}
	
	@inlinable
	public static func -= (lhs: inout Self, rhs: Self) {
		lhs.value = lhs.value.subtracting(rhs.value, modulo: Self.Order)
	}
	
	@inlinable
	public static func *= (lhs: inout Self, rhs: Self) {
		lhs.value = lhs.value.multiplying(rhs.value, modulo: Self.Order)
	}
	
	@inlinable
	public static func /= (lhs: inout Self, rhs: Self) {
		guard rhs.value != 0 else { fatalError("Division by zero") }
		guard let inverse = rhs.value.inverse(modulo: Self.Order) else {
			fatalError("Order is not prime")
		}
		lhs.value = lhs.value.multiplying(inverse, modulo: Self.Order)
	}
	
	@inlinable
	public static func %= (lhs: inout Self, rhs: Self) {
		lhs.value %= rhs.value
	}
	
	@inlinable
	public static func &= (lhs: inout Self, rhs: Self) {
		lhs.value &= rhs.value
	}
	
	@inlinable
	public static func |= (lhs: inout Self, rhs: Self) {
		lhs.value |= rhs.value
		if lhs.value < 0 { lhs.value = 0 }
		else if lhs.value >= Self.Order { lhs.value = Self.Order - 1 }
	}
	
	@inlinable
	public static func ^= (lhs: inout Self, rhs: Self) {
		lhs.value ^= rhs.value
		if lhs.value < 0 { lhs.value = 0 }
		else if lhs.value >= Self.Order { lhs.value = Self.Order - 1 }
	}
	
	@inlinable
	public static func >>= <RHS: BinaryInteger>(lhs: inout Self, rhs: RHS) {
		lhs.value >>= rhs
		if lhs.value < 0 { lhs.value = 0 }
		else if lhs.value >= Self.Order { lhs.value = Self.Order - 1 }
	}
	
	@inlinable
	public static func <<= <RHS: BinaryInteger>(lhs: inout Self, rhs: RHS) {
		lhs.value <<= rhs
		if lhs.value < 0 { lhs.value = 0 }
		else if lhs.value >= Self.Order { lhs.value = Self.Order - 1 }
	}
}

/// Exponentiation
extension FiniteFieldInteger {
	@inlinable
	public func exponentiating(by exponent: Self) -> Self {
		var copy = self
		copy.value = copy.value.exponentiating(by: exponent.value,
		                                       modulo: Self.Order)
		return copy
	}
}

/// Random
extension FiniteFieldInteger where Element: FixedWidthInteger {
	@inlinable
	public static func random(in range: ClosedRange<Self>) -> Self {
		var systemGenerator = SystemRandomNumberGenerator()
		return Self.random(in: range, using: &systemGenerator)
	}
	
	@inlinable
	public static func random(in range: Range<Self>) -> Self {
		var systemGenerator = SystemRandomNumberGenerator()
		return Self.random(in: range, using: &systemGenerator)
	}
	
	@inlinable
	public static func random<T: RandomNumberGenerator>(in range: Range<Self>, using generator: inout T) -> Self {
		precondition(!range.isEmpty, "Can't get random value with an empty range")
		let delta = range.upperBound - range.lowerBound
		let random: Element = generator.next(upperBound: delta.value)
		return range.lowerBound + Self(random)
	}
	
	@inlinable
	public static func random<T: RandomNumberGenerator>(in range: ClosedRange<Self>, using generator: inout T) -> Self {
		precondition(!range.isEmpty, "Can't get random value with an empty range")
		let delta = range.upperBound - range.lowerBound + 1
		if delta == 0 {
			return Self(generator.next(upperBound: Self.Order))
		}
		let random: Element = generator.next(upperBound: delta.value)
		return range.lowerBound + Self(random)
	}
}

/// Custom Conformance
extension FiniteFieldInteger {
	@inlinable
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.value == rhs.value
	}
	
	@inlinable
	public static func < (lhs: Self, rhs: Self) -> Bool {
		return lhs.value < rhs.value
	}
}
