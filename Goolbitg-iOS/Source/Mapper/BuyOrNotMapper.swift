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
        let goodVoteCount = dto.goodVoteCount ?? 0
        let badVoteCount = dto.badVoteCount ?? 0
        let result: GoodOrBadOrNot
        if goodVoteCount > badVoteCount {
            result = .good
        } else if goodVoteCount < badVoteCount {
            result = .bad
        } else {
            result = .none
        }
        return BuyOrNotCardViewEntity(
            id: String(dto.id ?? 0),
            userID: dto.writerId ?? "",
            imageUrl: URL(string: dto.productImageUrl ?? ""),
            itemName: dto.productName,
            priceString: GBNumberForMatter.shared.changeForCommaNumber(String(dto.productPrice)),
            goodReason: dto.goodReason,
            badReason: dto.badReason,
            goodVoteCount: String(goodVoteCount),
            badVoteCount: String(badVoteCount),
            goodMoreOrBadMore: result
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
