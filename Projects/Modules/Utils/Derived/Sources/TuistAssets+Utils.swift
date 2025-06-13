// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// MARK: - Asset Catalogs

public enum UtilsAsset: Sendable {
  public static let accentColor = UtilsColors(name: "AccentColor")
  public static let appleLogo = UtilsImages(name: "Apple_Logo")
  public static let bad = UtilsImages(name: "Bad")
  public static let cameraLogoV2 = UtilsImages(name: "CameraLogoV2")
  public static let checkBox2 = UtilsImages(name: "CheckBox2")
  public static let checkPopup = UtilsImages(name: "CheckPopup")
  public static let good = UtilsImages(name: "Good")
  public static let group = UtilsImages(name: "Group")
  public static let infoTip = UtilsImages(name: "InfoTip")
  public static let kakaoLogo = UtilsImages(name: "Kakao_Logo")
  public static let loginAppLogo = UtilsImages(name: "Login_AppLogo")
  public static let logo3 = UtilsImages(name: "Logo3")
  public static let pushChallenge = UtilsImages(name: "PushChallenge")
  public static let pushChatting = UtilsImages(name: "PushChatting")
  public static let pushNull = UtilsImages(name: "PushNull")
  public static let pushVote = UtilsImages(name: "PushVote")
  public static let secretRoom = UtilsImages(name: "SecretRoom")
  public static let splashBack = UtilsImages(name: "SplashBack")
  public static let trophy = UtilsImages(name: "Trophy")
  public static let user = UtilsImages(name: "User")
  public static let won = UtilsImages(name: "Won")
  public static let alertLogoV2 = UtilsImages(name: "alertLogoV2")
  public static let alertTriangle = UtilsImages(name: "alertTriangle")
  public static let appLogo2 = UtilsImages(name: "appLogo2")
  public static let appLogoEX = UtilsImages(name: "appLogoEX")
  public static let back = UtilsImages(name: "back")
  public static let bell = UtilsImages(name: "bell")
  public static let box = UtilsImages(name: "box")
  public static let bridge = UtilsImages(name: "bridge")
  public static let buyOrNotAdd = UtilsImages(name: "buyOrNotAdd")
  public static let challenge = UtilsImages(name: "challenge")
  public static let checkChecked = UtilsImages(name: "checkChecked")
  public static let checkDisabled = UtilsImages(name: "checkDisabled")
  public static let checkEnabled = UtilsImages(name: "checkEnabled")
  public static let checked = UtilsImages(name: "checked")
  public static let chevronDown = UtilsImages(name: "chevronDown")
  public static let community2 = UtilsImages(name: "community2")
  public static let disLikeHand = UtilsImages(name: "disLikeHand")
  public static let document = UtilsImages(name: "document")
  public static let greenCard = UtilsImages(name: "greenCard")
  public static let greenLogo = UtilsImages(name: "greenLogo")
  public static let headPhone = UtilsImages(name: "headPhone")
  public static let home = UtilsImages(name: "home")
  public static let homeBack = UtilsImages(name: "homeBack")
  public static let imageAuth = UtilsImages(name: "imageAuth")
  public static let likeHand = UtilsImages(name: "likeHand")
  public static let logoStud = UtilsImages(name: "logoStud")
  public static let miniAward = UtilsImages(name: "miniAward")
  public static let miniBurn = UtilsImages(name: "miniBurn")
  public static let miniChallendar = UtilsImages(name: "miniChallendar")
  public static let miniLikeHand = UtilsImages(name: "miniLikeHand")
  public static let miniUnLikeHand = UtilsImages(name: "miniUnLikeHand")
  public static let myBg = UtilsImages(name: "myBg")
  public static let myPage = UtilsImages(name: "myPage")
  public static let pencilImg = UtilsImages(name: "pencilImg")
  public static let plusLogo = UtilsImages(name: "plusLogo")
  public static let rightCh = UtilsImages(name: "rightCh")
  public static let settingBtn = UtilsImages(name: "settingBtn")
  public static let trash = UtilsImages(name: "trash")
  public static let unchecked = UtilsImages(name: "unchecked")
  public static let warning = UtilsImages(name: "warning")
  public static let warningPop = UtilsImages(name: "warningPop")
  public static let xSmall = UtilsImages(name: "xSmall")
}

// MARK: - Implementation Details

public final class UtilsColors: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  public var color: Color {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIColor: SwiftUI.Color {
      return SwiftUI.Color(asset: self)
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension UtilsColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: UtilsColors) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
  init(asset: UtilsColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct UtilsImages: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: UtilsImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: UtilsImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: UtilsImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
