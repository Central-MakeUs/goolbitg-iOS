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
    
    // 외부 주입
    @Binding private var isExpanded: Bool
    @Binding private var isDragging: Bool
    
    private let popupContent: PopupContent
    private let collapsedHeight: CGFloat
    
    
    let currentOffsetPercent: ((CGFloat) -> Void)?

    public init(
        isExpanded: Binding<Bool>,
        isDraging: Binding<Bool>,
        popupContent: PopupContent,
        collapsedHeight: CGFloat,
        currentOffsetPercent: ((CGFloat) -> Void)? = nil
    ) {
        self._isExpanded = isExpanded
        self._isDragging = isDraging
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
                                isDragging = true
                                if value.location.y < 0 {
                                    return
                                }
                                if isExpanded && value.startLocation.y - value.location.y > 0 {
                                    return
                                }
                                state = min(value.translation.height, sheetHeight)
                            }
                            .onEnded { value in
                                if value.translation.height < -80 {
                                    isExpanded = true
                                } else if value.translation.height > 80 {
                                    isExpanded = false
                                }
                                isDragging = false
                            }
                    )
                    .animation(.easeOut(duration: 0.1), value: isExpanded)
            }
            .frame(maxHeight: .infinity)
            .background {
                let percent = calcPercent(offsetY)
                BlurView(style: .systemUltraThinMaterialDark)
                    .opacity(percent)
                    .animation(.easeInOut(duration: 0.15), value: isExpanded)
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
        isDraging: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        currentOffsetPercent: ((CGFloat) -> Void)? = nil
    ) -> some View {
        self.modifier(
            DragBottomSheet(
                isExpanded: isExpanded,
                isDraging: isDraging,
                popupContent: content(),
                collapsedHeight: collapsedHeight,
                currentOffsetPercent: currentOffsetPercent
            )
        )
    }
}
