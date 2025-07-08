// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription
    import TuistExtensions

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: getProjectPackageSetting,
        baseSettings: .appSettings
    )
#endif

let package = Package(
    name: "Goolbitg-iOS-Lib",
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.1.3")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "1.17.1"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.8.1")),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMajor(from: "2.23.0")),
        .package(url: "https://github.com/airbnb/lottie-ios.git", .upToNextMajor(from: "4.5.1")),
        .package(url: "https://github.com/exyte/PopupView", .upToNextMajor(from: "4.0.1")),
        .package(url: "https://github.com/realm/realm-swift.git", exact: "10.54.0"),
//        .package(url: "https://github.com/Kitura/Swift-JWT.git", .upToNextMajor(from: "4.0.2")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.1.1")),
        .package(url: "https://github.com/alexiscreuzot/SwiftyGif.git", .upToNextMajor(from: "5.4.5")),
        .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators", exact: "0.11.0"),
        .package(url: "https://github.com/Little-tale/SwiftImageCompressor.git", .upToNextMajor(from: "0.0.3"))
    ]
)
