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
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ViewWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
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
