//
//  GBSwitchButton.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/29/25.
//

import SwiftUI

struct GBSwitchButton: View {
    
    let switchTitles: [String]
    @Binding var selectedIndex: Int
    let backGroundColor: Color
    let capsuleColor: Color
    let defaultTextColor: Color
    let selectedTextColor: Color
    
    var body: some View {
        contentView
    }
}

extension GBSwitchButton {
    private var contentView: some View {
        GeometryReader { geometry in
            let buttonWidth = geometry.size.width / CGFloat(switchTitles.count)
            
            ZStack(alignment: .leading) {
                // 움직이는 캡슐
                Capsule()
                    .fill(capsuleColor)
                    .frame(width: buttonWidth , height: geometry.size.height * 0.8)
                    .offset(x: CGFloat(selectedIndex) * buttonWidth)
                    .animation(.snappy, value: selectedIndex)
                
                HStack(spacing: 0) {
                    ForEach(Array(switchTitles.enumerated()), id: \.element.self) { index, item in
                        Text(item)
                            .font(selectedIndex == index ? FontHelper.btn4.font : FontHelper.body4.font)
                            .foregroundStyle(selectedIndex == index ? selectedTextColor : defaultTextColor)
                            .frame(width: buttonWidth, height: geometry.size.height)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    selectedIndex = index
                                }
                            }
                    }
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    @Previewable @State var currentIndex: Int = 0
    
    GBSwitchButton(
        switchTitles: ["진행중", "진행완료"],
        selectedIndex: $currentIndex,
        backGroundColor: GBColor.grey500.asColor,
        capsuleColor: GBColor.white.asColor,
        defaultTextColor: GBColor.grey300.asColor,
        selectedTextColor: GBColor.black.asColor
    )
    .frame(width: 200, height: 60) // 테스트용 크기 설정
}
#endif
