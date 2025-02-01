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
    static let agreeAndConditionStart = "약관 동의하고 시작하기"
    static let nextTitle = "다음으로"
    static let skipTitle = "건너뛰기"
    static let acceptTitle = "적용하기"
    static let sharedTitle = "공유하기"
    
    // MARK: AUTH Request View Text for GB
    static let authRequestHeaderTitle = "저희 굴비잇기를 위해\n이용할 정보를 작성해주세요"
    static let authRequestHeaderSub = "맞춤형 소비습관 형성 패턴을\n분석할 때 활용하고 있어요"
    
    static let authRequestNickNameTitle = "닉네임"
    static let authRequestNickNamePlaceHolder = "6자 이내로 작성해 주세요"
    static let authRequestDuplicatedCheck = "중복검사"
    
    static let authRequestBirthDayPlaceHolder = "생년월일을 선택해주세요"
    static let authRequestBirthDayTitle = "생년월일"
    static let authRequestBirthDayPlaceHolderYear = "YYYY"
    static let authRequestBirthDayPlaceHolderMonth = "MM"
    static let authRequestBirthDayPlaceHolderDay = "DD"
    
    static let authNickNameAlreadyUse = "이미 사용중인 닉네임 입니다."
    static let authNickNameOverOrUnderText = "2자이상 6자 이내로 작성해주세요"
    static let authNickNameKoreanOrEnglishNotText = "닉네임은 한글, 영문 대소문자만 입력할 수 있어요"
    static let authNickNameAllowText = "사용 가능한 닉네임 입니다."
    
    static let authRequestGenderTitle = "성별"
    static let authRequestGenderMale = "남자"
    static let authRequestGenderFemale = "여성"
    
    static let authRequestWellComeToGoolB = "굴비잇기에 오신 걸 환영해요"
    static let authRequestAgree = "서비스 사용전 가입 및 정보 제공에 동의해 주세요"
    static let allAgreeText = "전체동의"
    static let overFourTeenText = "[필수] 만 14세 이상입니다."
    static let serviceAgreementText = "[필수] 서비스 이용약관"
    static let privacyPolicyText = "[필수] 개인정보 보호정책"
    static let adAgreementText = "[선택] 맞춤형 광고 및 개인정보 제공 동의"
    
    // MARK: Shopping Check List
    static let shoppingCheckListHeaderTitle = "쇼핑중독 체크리스트"
    static let shoppingCheckListHeaderSub = "본인이 생각하는 소비습관을"
    static let shoppingCheckListPointText = "모두"
    static let shoppingCheckListPointTrailingText = "선택해 주세요"
    static let checkList1 = "스스로 통제하지 못한다"
    static let checkList2 = "쇼핑할 때 죄책감이 든다"
    static let checkList3 = "쇼핑할 때 긴장이나 불안감이 풀어진다"
    static let checkList4 = "쇼핑은 필요보다 그 자체를 즐긴다"
    static let checkList5 = "쇼핑 후 사용하지 않는 물건이 가득하다"
    static let checkList6 = "물건을 사면 기분이 좋아진다"
    
    // MARK: 소비습관 체크
    static let ConsumptionScore = "소비 습관 점수"
    static let ConsumptionToolTip = "평균 수입에 대한 평균 저축률을 기반으로\n소비 점수를 계산해주고 있어요"
    static let consumptionOverconsumptionIndexMeasurement = "본인의 평균 수입과 저축으로\n과소비 지수를 측정해드려요!"
    static let consumptionAverageMonthlyIncome = "월 평균 수입"
    static let consumptionAverageMonthlyIncomeWrite = "₩ 월 평균 수입 금액을 작성해 주세요"
    
    static let consumptionAverageMonthlySavings = "월 평균 저축"
    static let consumptionAverageMonthlySavingsWrite = "₩ 월 평균 저축 금액을 작성해 주세요"
    
    static let consumptionAverageMonthlyIncomeBigger = "월 평균 수입보다 큰 금액을 작성할 수 없습니다"
    
    // MARK: 지출 요일/시간 입력
    static let expenditureSelectMainTitle = "지출 요일/시간 선택"
    static let expenditureWriteYourTimeAndDay = "본인이 무슨 시간 무슨 요일에\n지출이 많은지 작성해보세요"
    static let expenditureWeakDay = "주 지출 요일"
    static let expenditureWeakTime = "주 지출 시간"
    static let expenditureUsuallySelectDay = "주로 소비하는 요일을 선택해 주세요"
    
    // MARK: 분석중
    static let analyzingConsumptionTitle = "소비유형을\n분석하고 있어요!"
    static let analyzingConsumptionSubTitle = "조금만 기다리면,\n나의 소비 유형을 받아볼 수 있어요!"
    
    // MARK: 분석 완료
    static let resultHabitRecommendationTitle = "나만의 맞춤형 소비습관을 추천받거나\n주변에 내 소비 유형을 공유해보세요"
    
    static let fitMeHabitStart = "나에게 맞는 소비습관 형성하기"
    
    // MARK: 챌린지 추가
    static let challengeTryTitle = "도전하기"
    static let challengeAddTitle = "챌린지 추가"
    static let challengeWhatMakeTitle = "님,\n어떤 습관을 만들어 볼까요?"
    static let challengeChoiceWhatYouWantToHabitOne = "만들고 싶은 습관 1개를 선택해주세요"
    static let challengeSameFamousSpendingChallenge = "같은 소비유형 인기 챌린지"
    static let challengeHowAboutAnotherHabitOne = "그 외 이런습관은 어때요?"
    
    // MARK: 마이페이지
    static let accountSetting = "계정 관리"
    static let accountID = "아이디"
    static let serviceInfo = "이용 안내"
    static let logOut = "로그아웃"
    static let serviceRevoke = "서비스 탈퇴"
    static let myPage = "마이페이지"
    static let mySpendingScoreTitle = "내 소비 점수"
    static let totalChallengeCount = "총 챌린지 수"
    static let writeCount = "작성한 글"
}
