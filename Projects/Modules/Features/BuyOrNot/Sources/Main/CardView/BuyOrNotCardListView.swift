//
//  BuyOrNotCardListView.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/15/25.
//

import SwiftUI
import Data

struct BuyOrNotCardListView: View {

    @Binding var currentListEntity: [BuyOrNotCardViewEntity]
    /// 현재 화면 중앙에 위치한 카드의 인덱스
    @Binding var currentIndex: Int

    let size: CGSize

    let selectedEntity: (BuyOrNotCardViewEntity) -> Void
    let reportEntity: (BuyOrNotCardViewEntity) -> Void
    let messageTap: (BuyOrNotCardViewEntity) -> Void

    /// 사용자가 드래그 중인 이동 거리
    @State private var dragOffset: CGFloat = 0
    /// 드래그 종료 후 고정된 오프셋 위치
    @State private var lastOffset: CGFloat = 0

    // MARK: - Layout Constants
    private let horizontalPadding: CGFloat = 24
    /// 비활성 카드의 축소 비율 (0.8 = 80% 크기)
    private let reducedScale: CGFloat = 0.8
    /// 카드 간 간격 조절을 위한 너비 배율
    private let sidePaddingScale: CGFloat = 0.89
    /// 스와이프로 인덱스 전환이 발생하는 최소 속도 (pt/s)
    private let velocityThreshold: CGFloat = 400
    private let snapAnimationDuration: TimeInterval = 0.3

    /// 카드 하나의 렌더링 너비 (좌우 패딩 제외)
    private var cardWidth: CGFloat {
        size.width - (horizontalPadding * 2)
    }

    /// 카드 한 장이 차지하는 전체 너비 (카드 너비 * 배율 + 간격)
    private var cardStepWidth: CGFloat {
        cardWidth * sidePaddingScale + horizontalPadding
    }

    /// 마지막 유효 인덱스
    private var lastIndex: Int {
        max(0, currentListEntity.count - 1)
    }

    var body: some View {
        GeometryReader { _ in
            LazyHStack(spacing: 0) {
                ForEach(Array(currentListEntity.enumerated()), id: \.element.id) { item in
                    let entity = item.element

                    GeometryReader { proxy in
                        let midX = proxy.frame(in: .global).midX
                        let scale = scaleEffect(forMidX: midX)

                        BuyOrNotCardView(entity: entity) {
                            reportEntity(entity)
                        } messageTab: {
                            messageTap(entity)
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
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        // 수직 드래그가 수평보다 크면 스크롤에 양보
                        guard abs(value.translation.width) >= abs(value.translation.height) else {
                            return
                        }
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let velocityX = value.velocity.width
                        let targetIndex: Int

                        if abs(velocityX) > velocityThreshold {
                            // 빠른 스와이프: 속도 방향으로 한 장 이동
                            targetIndex = indexByVelocity(velocityX)
                        } else {
                            // 느린 드래그: 가장 가까운 카드에 스냅
                            targetIndex = nearestIndex()
                        }

                        currentIndex = targetIndex
                        lastOffset = -CGFloat(targetIndex) * cardStepWidth
                        dragOffset = 0
                    }
            )
            .animation(.smooth(duration: snapAnimationDuration), value: currentIndex)
            .animation(.linear(duration: 0.2), value: dragOffset)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Scale

    /// 화면 중심으로부터의 거리에 비례하여 카드 크기를 조절한다.
    /// - Parameter midX: 카드의 글로벌 X 중심 좌표
    /// - Returns: 0.85 ~ 1.0 범위의 스케일 값
    private func scaleEffect(forMidX midX: CGFloat) -> CGFloat {
        let centerX = size.width / 2
        let normalizedDistance = abs(midX - centerX) / size.width
        let scale = 1 - (normalizedDistance * (1 - reducedScale))
        return scale.clamped(to: 0.85...1.0)
    }

    // MARK: - Index Calculation

    /// 현재 오프셋 기준으로 가장 가까운 카드 인덱스를 반환한다.
    /// - Note: `lastOffset + dragOffset`의 총 이동량에서 반올림으로 결정
    private func nearestIndex() -> Int {
        let totalOffset = -lastOffset - dragOffset
        let approximateIndex = totalOffset / cardStepWidth
        return Int(round(approximateIndex)).clamped(to: 0...lastIndex)
    }

    /// 스와이프 속도 방향에 따라 인덱스를 한 칸 이동한다.
    /// - Parameter velocityX: 수평 스와이프 속도 (음수 = 왼쪽, 양수 = 오른쪽)
    private func indexByVelocity(_ velocityX: CGFloat) -> Int {
        if velocityX < 0 {
            return min(lastIndex, currentIndex + 1)
        } else {
            return max(0, currentIndex - 1)
        }
    }
}

// MARK: - Comparable + Clamped

private extension Comparable {
    /// 값을 지정 범위 내로 제한한다.
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#if DEBUG
struct TestListView: View {
    @State var currentList: [BuyOrNotCardViewEntity] = []
    
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
                    }, messageTap: { _ in
                        
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
