//
//  BuyOrNotMapper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 2/16/25.
//

import Foundation
import ComposableArchitecture

final class BuyOrNotMapper: Sendable {
  
    func toEntity(dtos: [BuyOrNotDTO]) async -> [BuyOrNotCardViewEntity] {
        await dtos.asyncMap { toEntity(dto: $0) }
    }
    
    func toEntity(dto: BuyOrNotDTO) -> BuyOrNotCardViewEntity {
        return BuyOrNotCardViewEntity(
            id: String(dto.id ?? 0),
            userID: dto.writerId ?? "",
            imageUrl: URL(string: dto.productImageUrl ?? ""),
            itemName: dto.productName,
            priceString: GBNumberForMatter.shared.changeForCommaNumber(String(dto.productPrice)),
            goodReason: dto.goodReason,
            badReason: dto.badReason,
            goodVoteCount: String(dto.goodVoteCount ?? 0),
            badVoteCount: String(dto.badVoteCount ?? 0)
        )
    }
}

extension BuyOrNotMapper: DependencyKey {
    static let liveValue: BuyOrNotMapper = BuyOrNotMapper()
}

extension DependencyValues {
    var buyOrNotMapper: BuyOrNotMapper {
        get { self[BuyOrNotMapper.self] }
        set { self[BuyOrNotMapper.self] = newValue }
    }
}
