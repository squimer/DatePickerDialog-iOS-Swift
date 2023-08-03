// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "DatePickerDialog",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "DatePickerDialog",
            targets: ["DatePickerDialog"])
    ],
    targets: [
        .target(
            name: "DatePickerDialog",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "DatePickerDialogTests",
            dependencies: ["DatePickerDialog"],
            path: "Tests"
        )
    ]
)
