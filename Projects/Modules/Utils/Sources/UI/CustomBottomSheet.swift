//
//  CustomBottomSheet.swift
//  Utils
//
//  Created by Jae hyung Kim on 6/30/26.
//

import SwiftUI

public struct CustomBottomSheet<Content>: View where Content: View {

    @Binding public var isPresented: Bool
    public let height: CGFloat?
    public let content: Content

    @GestureState private var translation: CGFloat = .zero
    @State private var measuredContentHeight: CGFloat = .zero
    @State private var settledDragOffset: CGFloat = .zero

    private let handleAreaHeight: CGFloat = 30
    
    @Environment(\.safeAreaInsets) var safeAreaInset

    public init(
        _ isPresented: Binding<Bool>,
        height: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.height = height
        self.content = content()
    }

    private var resolvedContentHeight: CGFloat {
        max(height ?? measuredContentHeight, 0)
    }

    public var body: some View {
        VStack(spacing: .zero) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(height: handleAreaHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .foregroundStyle(.gray)
                        .frame(width: 30, height: 5)
                )

            sheetContent
            EmptyView().frame(height: safeAreaInset.bottom)
        }
        .frame(height: resolvedContentHeight + handleAreaHeight)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
                .ignoresSafeArea(edges: .bottom)
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .offset(y: max(0, settledDragOffset + translation))
        .gesture(dragGesture)
        .onChange(of: isPresented) { newValue in
            if newValue {
                settledDragOffset = .zero
            }
        }
    }

    @ViewBuilder
    private var sheetContent: some View {
        if let height {
            content
                .frame(height: height)
        } else {
            content
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: BottomSheetHeightPreferenceKey.self,
                                value: proxy.size.height
                            )
                    }
                }
                .onPreferenceChange(BottomSheetHeightPreferenceKey.self) { newValue in
                    if abs(newValue - measuredContentHeight) > 0.5 {
                        measuredContentHeight = newValue
                    }
                }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($translation) { value, state, _ in
                if value.translation.height >= 0 {
                    let maxTranslation = max(resolvedContentHeight, 1)
                    state = min(maxTranslation, value.translation.height)
                }
            }
            .onEnded { value in
                if value.translation.height >= max(resolvedContentHeight, 1) / 3 {
                    settledDragOffset = max(0, value.translation.height)
                    isPresented = false
                } else {
                    settledDragOffset = .zero
                }
            }
    }
}

public struct CustomBottomSheetModifier<SheetContent>: ViewModifier where SheetContent: View {

    @Binding var isPresented: Bool
    let height: CGFloat?
    let dismissOnTap: Bool
    let sheetContent: () -> SheetContent

    @State private var isMounted: Bool = false
    @State private var isVisible: Bool = false

    private let animationDuration: Double = 0.3

    public func body(content: Content) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                content

                if isMounted {
                    Color.black
                        .opacity(isVisible ? 0.25 : 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if dismissOnTap {
                                isPresented = false
                            }
                        }
                        .allowsHitTesting(isVisible)

                    CustomBottomSheet($isPresented, height: height) {
                        sheetContent()
                    }
                    .offset(y: isVisible ? 0 : max(proxy.size.height, 1))
                    .allowsHitTesting(isVisible)
                }
            }
            .onAppear {
                syncPresentation(isPresented)
            }
            .onChange(of: isPresented) { newValue in
                syncPresentation(newValue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .animation(.easeInOut(duration: animationDuration), value: isVisible)
    }

    private func syncPresentation(_ show: Bool) {
        if show {
            if !isMounted {
                isMounted = true
            }
            withAnimation(.easeInOut(duration: animationDuration)) {
                isVisible = true
            }
        } else {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isVisible = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                if !isPresented {
                    isMounted = false
                }
            }
        }
    }
}

private struct BottomSheetHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

