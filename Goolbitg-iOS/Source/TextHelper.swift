//
//  TextHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import Foundation

enum TextHelper {
    
    
    // MARK: LOGIN
    static let kakaoLogin = "카카오톡으로 시작하기"
    static let appleLogin = "Apple로 로그인"
    
    // MARK: AUTH REQUEST
    static let authHeader = "시작하기 전에"
    static let authHeaderSub = "여러분의 더 나은 서비스 이용을 위해 몇가지\n동의가 필요한 내용을 확인해주세요"
    static let authAlertAccess = "알림 동의"
    static let authAlertAccessSub = "습관화를 위한 중요 알림을 받을 수 있어요"
    static let authCameraAccess = "카메라 활용 동의"
    static let authCameraAccessSub = "‘살까말까’ 이미지 촬영 시 필요해요"
    static let authAlbumAccess = "앨범 접근 허용 동의"
    static let authAlbumAccessSub = "‘살까말까’ 이미지 업로드 시 필요해요"
    
    // MARK: Common
    static let authStart = "시작하기"
    static let nextTitle = "다음으로"
    
    // MARK: AUTH Request View Text for GB
    static let authRequestHeaderTitle = "저희 굴비잇기를 위해\n이용할 정보를 작성해주세요"
    static let authRequestHeaderSub = "맞춤형 소비습관 형성 패턴을\n분석할 때 활용하고 있어요"
    
    static let authRequestNickNameTitle = "닉네임"
    static let authRequestNickNamePlaceHolder = "6자 이내로 작성해 주세요"
    static let authRequestDuplicatedCheck = "중복검사"
    
    static let authRequestBirthDayTitle = "생년월일"
    static let authRequestBirthDayPlaceHolderYear = "YYYY"
    static let authRequestBirthDayPlaceHolderMonth = "MM"
    static let authRequestBirthDayPlaceHolderDay = "DD"
    
    static let authRequestGenderTitle = "성별"
    static let authRequestGenderMale = "남자"
    static let authRequestGenderFemale = "여성"
    
    // MARK: Shopping Check List
    static let shoppingCheckListHeaderTitle = "쇼핑중독 체크리스트"
    static let shoppingCheckListHeaderSub = "본인이 생각하는 소비습관을"
    static let shoppingCheckListPointText = "모두"
    static let shoppingCheckListPointTrailingText = "선택해 주세요"
    
    // MARK: 소비습관 체크
    static let ConsumptionScore = "소비 습관 점수"
    static let ConsumptionToolTip = "평균 수입에 대한 평균 저축률을 기반으로\n소비 점수를 계산해주고 있어요"
    static let consumptionOverconsumptionIndexMeasurement = "본인의 평균 수입과 저축으로\n과소비 지수를 측정해드려요!"
    static let consumptionAverageMonthlyIncome = "월 평균 수입"
    static let consumptionAverageMonthlyIncomeWrite = "₩ 월 평균 수입 금액을 작성해 주세요"
    
    static let consumptionAverageMonthlySavings = "월 평균 저축"
    static let consumptionAverageMonthlySavingsWrite = "₩ 월 평균 저축 금액을 작성해 주세요"
    
    static let consumptionAverageMonthlyIncomeBigger = "월 평균 수입보다 큰 금액을 작성할 수 없습니다"
}
