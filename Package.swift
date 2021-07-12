// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReactiveStream",
    products: [
        .executable(
            name: "Demo",
            targets: ["Demo"]
        ),
        .library(
            name: "ReactiveStream",
            targets: ["ReactiveStream"]),
        .library(
            name: "Atomics",
            targets: ["Atomics"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Demo",
            dependencies: []),
        .target(
            name: "AtomicsCore",
            dependencies: []),
        .target(
            name: "Atomics",
            dependencies: [
                "AtomicsCore"
            ]),
        .target(
            name: "ReactiveStream",
            dependencies: [
                "Atomics",
            ]),
        .target(
            name: "TestUtilities",
            dependencies: []),
        .testTarget(
            name: "ReactiveStreamTests",
            dependencies: [
                "ReactiveStream",
                "TestUtilities",
            ]),
        .testTarget(
            name: "CompatibilityTests",
            dependencies: [
                "ReactiveStream",
                "TestUtilities",
            ]),
        .testTarget(
            name: "AtomicTests",
            dependencies: [
                "Atomics",
            ])
    ],
    cxxLanguageStandard: .cxx1z
)
