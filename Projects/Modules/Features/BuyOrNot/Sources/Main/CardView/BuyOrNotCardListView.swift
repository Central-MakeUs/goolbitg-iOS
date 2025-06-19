//
//  BuyOrNotCardListView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import Data
import Utils

struct BuyOrNotCardListView: View {
    
    @Binding var currentListEntity: [BuyOrNotCardViewEntity]
    @Binding var currentIndex: Int // 현재 선택된 카드의 인덱스
    
    let size: CGSize
    
    let selectedEntity: (BuyOrNotCardViewEntity) -> Void
    let reportEntity: (BuyOrNotCardViewEntity) -> Void
    
    
    @State private var dragOffset: CGFloat = 0  // 사용자의 드래그 이동 거리
    @State private var lastOffset: CGFloat = 0  // 마지막으로 멈춘 위치
    @State private var isDragging: Bool = false  // 드래그 중인지 확인
    
    private let horizontalPadding: CGFloat = ifiPadOS ? 40 : 24 // 좌우 여백
    private let reducedScale: CGFloat = 0.8  // 좌우 카드 크기 축소 비율
    private let sidePaddingScale: CGFloat = 0.89 // 사이드 스케일
    private let velocityThreshold: CGFloat = 400 // 드래그 속도
    
    var cardWidth: CGFloat {
        let cardWidth: CGFloat = size.width - (horizontalPadding * 2)
        return cardWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            LazyHStack(spacing: 0) {
                ForEach(Array(currentListEntity.enumerated()), id: \.element.id) { item in
                    let entity = item.element
                    
                    GeometryReader { proxy in
                        let minX = proxy.frame(in: .global).midX
                        let scale = getScaleEffect(for: minX)
                        
                        BuyOrNotCardView(entity: entity) {
                            reportEntity(entity)
                        }
                        .onTapGesture {
                            selectedEntity(entity)
                        }
                        .scaleEffect(scale)
                        .frame(width: cardWidth, height: size.height)
                    }
                    .frame(width: cardWidth * sidePaddingScale)
                    .padding(.trailing, horizontalPadding)
                }
            }
            .padding(.leading, horizontalPadding)
            .offset(x: dragOffset + lastOffset)
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        let verticalDrag = abs(value.predictedEndTranslation.height)
                        let horizontalDrag = abs(value.predictedEndTranslation.width)
                        
                        if verticalDrag > horizontalDrag {
                            return
                        }
                        withAnimation(.easeInOut(duration: 0.1)) {
                            dragOffset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        let newIndex = getNearestIndex()
                        
                        let newOffset = -CGFloat(newIndex) * (cardWidth * sidePaddingScale + horizontalPadding)
                        
                        withAnimation(.bouncy(duration: 0.4)) {
                            currentIndex = newIndex
                            lastOffset = newOffset
                            dragOffset = 0
                        }
                    }
            )
        }
        .scrollIndicators(.hidden)
    }
    
    /// 위치에 따라 카드의 크기를 조절하는 함수
    private func getScaleEffect(for minX: CGFloat) -> CGFloat {
        let screenWidth = size.width
        let centerX = screenWidth / 2
        let distance = abs(minX - centerX) / screenWidth
        let scaleFactor = 1 - (distance * (1 - reducedScale))
        
        return max(0.85, min(scaleFactor, 1.0)) // 최소 크기 0.85, 최대 크기 1.0으로 제한
    }
    
    /// 가장 가까운 카드 인덱스를 찾는 함수
    /// lastOffset : 이전에 멈췄던 X 좌표 오프셋 (즉, 마지막으로 카드가 멈춘 위치)
    /// dragOffset : 현재 드래그하고 있는 거리
    private func getNearestIndex() -> Int {
        // 하나의 카드가 차지하는 총 너비
        let oneCardWidth = cardWidth * sidePaddingScale + horizontalPadding
        let approximateIndex = (-lastOffset - dragOffset) / oneCardWidth
        // Min(count, round: 1.4 -> 1, 1.6 -> 2)
        return max(0, min(currentListEntity.count - 1, Int(round(approximateIndex))))
    }
}

#if DEBUG
struct TestListView: View {
    @State var currentList: [BuyOrNotCardViewEntity] = BuyOrNotCardViewEntity.dummy()
    
    @State var listIndex = 0
    
    var body: some View {
        ScrollView(.vertical) {
            GeometryReader { proxy in
                let size = proxy.size
                BuyOrNotCardListView(
                    currentListEntity: $currentList,
                    currentIndex: $listIndex,
                    size: size,
                    selectedEntity: { _ in
                        print("ASDASD")
                    }, reportEntity: { _ in
                        print("kjlkjlk")
                    }
                )
                .onChange(of: listIndex) { newValue in
                    print(newValue)
                }
            }
            .frame(height: 500)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    TestListView()
}
#endif
