# FiniteField

[![](https://img.shields.io/badge/Swift-5.0-orange.svg)][1]
[![](https://img.shields.io/badge/os-macOS%20|%20Linux-lightgray.svg)][1]
[![](https://travis-ci.com/std-swift/FiniteField.svg?branch=master)][2]
[![](https://codecov.io/gh/std-swift/FiniteField/branch/master/graph/badge.svg)][3]
[![](https://codebeat.co/badges/67405c92-663f-4b6f-8b4e-6889fac07b53)]()

[1]: https://swift.org/download/#releases
[2]: https://travis-ci.com/std-swift/FiniteField
[3]: https://codecov.io/gh/std-swift/FiniteField
[4]: https://codebeat.co/projects/github-com-std-swift-finitefield-master

Finite Fields in Swift

## Importing

```Swift
import FiniteField
```

```Swift
dependencies: [
	.package(url: "https://github.com/std-swift/FiniteField.git",
	         from: "1.0.0")
],
targets: [
	.target(
		name: "",
		dependencies: [
			"FiniteField"
		]),
]
```

## Using

`FiniteFieldInteger` is used to define finite fields containing `Order` integers starting from zero.

Sample declaration of a finite field of integers in the range `0..<31` backed by a `UInt8`:

```Swift
struct FF_31: FiniteFieldInteger {
	static var Order = UInt8(31)
	var value: Element = 0
}
```
