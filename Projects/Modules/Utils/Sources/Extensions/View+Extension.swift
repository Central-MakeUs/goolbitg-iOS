//
//  View+Extension.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import SwiftUI

public extension View {
    func asButton(action: @escaping () -> Void ) -> some View {
        return modifier(ButtonWrapper(action: action))
    }
    
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// LiquidGlassButton
    /// - Parameters:
    ///   - type: LiquidGlassButtonStyleType
    ///   - action: callBack
    func asLiquidGlassButton(
        type: LiquidGlassButtonStyleType = .glass,
        action: @escaping () -> Void
    ) -> some View {
        return modifier(LiquidGlassButtonWrapper(type: type, action: action))
    }
    
    /// asLiquidGlassView
    /// - Parameters:
    ///   - type: LiquidGlassType
    ///   - defaultShape: iff True -> DefaultGlassEffectShape() So ignored Shape
    ///   - shape: CustomShape
    func asLiquidGlassView(
        _ type: LiquidGlassType,
        defaultShape: Bool = true,
        shape: some Shape = .capsule
    ) -> some View {
        return modifier(LiquidViewStyleWrapper(type, defaultShape: defaultShape, shape: shape))
    }
    
}

public extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edge: edges).foregroundColor(color))
    }
    
    func cornerRadiusCorners(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self
            .clipShape(
                RoundedCornerShape(corners: corners, radius: radius)
            )
    }
    
    @ViewBuilder
    func changeTextColor(_ color: Color) -> some View {
        if UITraitCollection.current.userInterfaceStyle == .light {
            self.colorInvert().colorMultiply(color)
        } else {
            self.colorMultiply(color)
        }
    }
    
    /// viewLifeCycleChecker
    /// - Parameters:
    ///   - didLoadAction: viewDidLoadTrigger
    ///   - didAppearAction: viewDIdAppearTrigger
    /// - Returns: View
    func onViewRenderCycle(
        didLoadAction: @escaping () -> Void,
        didAppearAction: (() -> Void)? = nil
    ) -> some View {
        modifier(
            LifeCycleModifier(
                didLoadAction: didLoadAction,
                didAppearAction: didAppearAction
            )
        )
    }
}

public extension View {
    
    func snapshot(scale: CGFloat? = nil) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale ?? UIScreen.main.scale
        return renderer.uiImage
    }
    
    func asImage() -> Image {
        let image = self.snapshot()
        return Image(uiImage: image ?? UIImage())
    }
}

public extension View {
    @ViewBuilder
    func shimmering(
        active: Bool = true,
        animation: Animation = ShimmerAnimation.defaultAnimation,
        gradient: Gradient = ShimmerAnimation.defaultGradient,
        bandSize: CGFloat = 0.3,
        mode: ShimmerAnimation.Mode = .mask
    ) -> some View {
        if active {
            modifier(ShimmerAnimation(animation: animation, gradient: gradient, bandSize: bandSize, mode: mode))
        } else {
            self
        }
    }
    
    func skeletonEffect(
        animation: Animation = ShimmerAnimation.defaultAnimation,
        gradient: Gradient = ShimmerAnimation.defaultGradient,
        bandSize: CGFloat = 0.3
    ) -> some View {
        self.modifier(SkeletonModifier(animation: animation, bandSize: bandSize, gradient: gradient))
    }
}

// MARK: 뒤로가기 제스처
public extension View {
    func disableBackGesture(_ disabled: Bool = true) -> some View {
        self.modifier(DisableBackGesture(isGestureDisabled: disabled))
    }
}

public extension View {
    
    func subscribeKeyboardHeight(
        keyboardHeight: @escaping (
            CGFloat
        ) -> Void
    ) -> some View {
        self
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillShowNotification
                ),
                perform: { notification in
                    guard let userInfo = notification.userInfo,
                          let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                        return
                    }
                    
                    keyboardHeight(
                        keyboardRect.height
                    )
                    
                }).onReceive(
                    NotificationCenter.default.publisher(
                        for: UIResponder.keyboardWillHideNotification
                    ),
                    perform: { _ in
                        keyboardHeight(
                            0
                        )
            })
    }
}

// MARK: 동적 높이
struct ViewHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ViewWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
extension View {
    public func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ViewHeightKey.self, value: proxy.size.height)
            }
        }
        .onPreferenceChange(ViewHeightKey.self, perform: onChange)
    }
    
    public func readWidth(onChange: @escaping (CGFloat) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ViewWidthKey.self, value: proxy.size.width)
            }
        }
        .onPreferenceChange(ViewWidthKey.self, perform: onChange)
    }
}

// MARK: FocusTextField
extension View {
    
    @MainActor
    public func scrollToFocusedField(
        _ proxy: ScrollViewProxy,
        filedNumber: Int,
        completion: (() -> Void)?
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 0.7)) {
                proxy.scrollTo(filedNumber, anchor: .top)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                completion?()
            }
        }
    }
}

// MARK: FirstOnAppear
struct OnFirstAppearModifier: ViewModifier {
    let perform:() -> Void
    @State private var firstTime: Bool = true
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if firstTime {
                    firstTime = false
                    
                    perform()
                }
            }
    }
}
extension View {
    public func onFirstAppear(_ perform: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(perform: perform))
    }
}

extension View {
    public func ignoreAreaBackgroundColor(_ color: Color) -> some View {
        self
            .background {
                color
                    .ignoresSafeArea()
            }
    }
}

// MARK: ViewSize
extension View {
    
    public func onReadSize(_ perform: @escaping (CGSize) -> Void) -> some View {
        self.background(alignment: .center) {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }
}

// MARK: ScrollView Scroll
extension View {
    
    /// ScrollViewReader의 `ScrollViewProxy`를 사용해 지정한 `id` 위치로 스크롤합니다.
    /// main queue 다음 런루프 사이클에서 실행되도록 지연 호출 합니다.
    ///
    /// - Parameters:
    ///   - proxy: `ScrollViewReader`로부터 전달받은 `ScrollViewProxy`.
    ///   - id: 스크롤할 대상 뷰의 식별자. 대상 뷰는 `.id(_:)`로 동일한 값을 가져야 합니다.
    ///   - point: 스크롤 완료 시 정렬할 앵커 지점. 예: `.top`, `.center`, `.bottom`. 기본값은 `nil`(시스템 기본).
    ///   - animation: 애니메이션을 사용해 스크롤할지 여부. 기본값은 `false`.
    ///
    /// - Note: 제네릭 매개변수 `ID`는 `Hashable`을 준수해야 합니다.
    /// - SeeAlso: `ScrollViewReader`, `ScrollViewProxy.scrollTo(_:anchor:)`
    public func scrollTo<ID>(
        proxy: ScrollViewProxy,
        id: ID,
        point: UnitPoint? = nil,
        animation: Bool = false
    ) where ID : Hashable {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if animation {
                withAnimation {
                    proxy.scrollTo(id, anchor: point)
                }
            } else {
                proxy.scrollTo(id, anchor: point)
            }
        }
    }
}

