//
//  CryptoBox.swift
//  Data
//
//  Created by Jae hyung Kim on 1/9/26.
//

import CryptoKit
import Foundation

enum CryptoBoxError: Error {
    /// SealedBox를 하나의 Data로 만들 수 없을 때
    case missingCombined
}

struct CryptoBox {

    /// AES-GCM으로 원본(Data)을 암호화해서 포맷(Data)으로 반환
    /// - Parameters:
    ///   - plaintext: 암호화할 원본 데이터(평문)
    ///   - key: 대칭키(SymmetricKey). 같은 키로 해야함
    /// - Returns:
    ///   - combined Data = nonce(IV) + ciphertext(암호문) + tag(인증태그)
    static func encrypt(_ plaintext: Data, using key: SymmetricKey) throws -> Data {

        // AES.GCM.seal:
        // 1) nonce(일회용 값) 자동 생성
        // 2) plaintext를 AES-GCM으로 암호화해 ciphertext 생성
        // 3) 무결성/변조 검사용 tag 생성
        // 결과를 SealedBox(봉인된 상자)로 돌려줌
        let sealed = try AES.GCM.seal(plaintext, using: key)

        // sealed.combined:
        // SealedBox의 (nonce, ciphertext, tag)를 하나로 합친 Data
        guard let combined = sealed.combined else {
            throw CryptoBoxError.missingCombined
        }

        return combined
    }

    /// AES-GCM 포맷(Data)을 복호화해서 원본(Data)으로 반환
    /// - Parameters:
    ///   - combined: encrypt Data
    ///   - key: encrypt에 사용한 것과 동일한 대칭키
    /// - Returns:
    ///   - 복호화된 원본 Data
    static func decrypt(_ combined: Data, using key: SymmetricKey) throws -> Data {

        // combined Data를 파싱해서 SealedBox로 복원
        // (길이가 이상하거나 포맷이 깨졌으면 여기서 throw)
        let box = try AES.GCM.SealedBox(combined: combined)

        // AES.GCM.open:
        // 1) tag로 무결성(변조 여부) 검증
        // 2) 검증 통과 시에만 복호화 수행 후 plaintext 반환
        // 3) 데이터가 조금이라도 바뀌었거나(변조), 키가 다르면 throw
        return try AES.GCM.open(box, using: key)
    }
}


// MARK: NOTE
/*
    # AES: 양방향 암호화, 대칭키 암호화, 상대적 빠름
    
    ## 암호화 과정
    > 256 기준 10,12,14 라운드 반복 구조
    > 각 라운드당 4가지 연산
 
    - SubBytes: 각 바이트 -> S-Box 표를 통해 비선형 변환
    - ShiftRows: 행을 기준으로 각 바이트를 좌측이동
    - MixColumns: 열 기준으로 행렬 곱셈수행
    - AddRoundKey: 라운드 키와 XOR 수행 블록 데이터 Mix
 
    ## 복호화 -> 암호화 역순
 */
