// swift-tools-version:5.0
//
//  Package.swift
//  FiniteField
//

import PackageDescription

let package = Package(
	name: "FiniteField",
	products: [
		.library(
			name: "FiniteField",
			targets: ["FiniteField"]),
	],
	dependencies: [
		.package(url: "https://github.com/std-swift/ModularArithmetic.git",
		         from: "1.0.0")
	],
	targets: [
		.target(
			name: "FiniteField",
			dependencies: ["ModularArithmetic"]),
		.testTarget(
			name: "FiniteFieldTests",
			dependencies: ["FiniteField"]),
	]
)
