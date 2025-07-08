//
//  DragBottomSheet.swift
//  FeatureCommon
//
//  Created by Jae hyung Kim on 6/16/25.
//

import SwiftUI

struct DragBottomSheet<PopupContent: View>: ViewModifier {
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var sheetHeight: CGFloat = 0
    @Binding private var isExpanded: Bool
    @State private var animated = false
    
    private let popupContent: PopupContent
    private let collapsedHeight: CGFloat
    
    let currentOffsetPercent: ((CGFloat) -> Void)?

    public init(
        isExpanded: Binding<Bool>,
        popupContent: PopupContent,
        collapsedHeight: CGFloat,
        currentOffsetPercent: ((CGFloat) -> Void)? = nil
    ) {
        self._isExpanded = isExpanded
        self.popupContent = popupContent
        self.collapsedHeight = collapsedHeight
        self.currentOffsetPercent = currentOffsetPercent
    }

    public func body(content: Content) -> some View {
        let offsetY = calculateOffsetY()
        
        return ZStack(alignment: .bottom) {
            content
            VStack(spacing: 0) {
                Spacer()
                
                popupContent
                    .fixedSize(horizontal: false, vertical: true)
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    sheetHeight = proxy.size.height
                                }
                        }
                    }
                    .offset(y: offsetY)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                if isExpanded && value.location.y < 0 {
                                    return
                                }
                                else if value.location.y < collapsedHeight {
                                    return
                                }
                                state = min(value.translation.height, sheetHeight)
                            }
                            .onEnded { value in
                                if value.translation.height < -50 {
                                    isExpanded = true
                                } else if value.translation.height > 50 {
                                    isExpanded = false
                                }
                                animated.toggle()
                            }
                    )
                    .animation(.easeOut(duration: 0.3), value: animated)
            }
            .frame(maxHeight: .infinity)
            .background {
                let percent = calcPercent(offsetY)
                BlurView(style: .systemUltraThinMaterialDark)
                    .opacity(percent)
                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    .onChange(of: percent) { newValue in
                        currentOffsetPercent?(newValue)
                    }
            }
        }
        .ignoresSafeArea()
    }
    
    private func calculateOffsetY() -> CGFloat {
        if isExpanded {
            return dragOffset
        }
        else {
            return dragOffset + sheetHeight - collapsedHeight
        }
    }
    
    private func calculateBlur(_ offsetY: CGFloat? = nil) -> CGFloat {
        return calcPercent(offsetY)
    }
    
    private func calcPercent(_ offsetY: CGFloat? = nil) -> CGFloat {
        let _min: CGFloat = 0
        let _max: CGFloat = 1
        let offset: CGFloat
        
        if let offsetY {
            offset = offsetY
        } else {
            offset = calculateOffsetY()
        }
        
        let normalized = _max - max(_min, min(offset / (sheetHeight - collapsedHeight), _max))
        return normalized
    }
}

extension View {
    public func dragBottomSheet<Content: View>(
        collapsedHeight: CGFloat = 0,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        currentOffsetPercent: ((CGFloat) -> Void)? = nil
    ) -> some View {
        self.modifier(
            DragBottomSheet(
                isExpanded: isExpanded,
                popupContent: content(),
                collapsedHeight: collapsedHeight,
                currentOffsetPercent: currentOffsetPercent
            )
        )
    }
}
