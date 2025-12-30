//
//  TextHelper.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/4/25.
//

import Foundation

public enum TextHelper {
    
    // MARK: LOGIN
    public static let kakaoLogin = "카카오톡으로 시작하기"
    public static let appleLogin = "Apple로 로그인"
    
    // MARK: AUTH REQUEST
    public static let authHeader = "시작하기 전에"
    public static let authHeaderSub = "여러분의 더 나은 서비스 이용을 위해 몇가지\n동의가 필요한 내용을 확인해주세요"
    public static let authAlertAccess = "알림 동의"
    public static let authAlertAccessSub = "습관화를 위한 중요 알림을 받을 수 있어요"
    public static let authCameraAccess = "카메라 활용 동의"
    public static let authCameraAccessSub = "‘살까말까’ 이미지 촬영 시 필요해요"
    public static let authAlbumAccess = "앨범 접근 허용 동의"
    public static let authAlbumAccessSub = "‘살까말까’ 이미지 업로드 시 필요해요"
    
    // MARK: Common
    public static let authStart = "시작하기"
    public static let agreeAndConditionStart = "약관 동의하고 시작하기"
    public static let nextTitle = "다음으로"
    public static let skipTitle = "건너뛰기"
    public static let acceptTitle = "적용하기"
    public static let sharedTitle = "공유하기"
    
    // MARK: AUTH Request View Text for GB
    public static let authRequestHeaderTitle = "저희 굴비잇기를 위해\n이용할 정보를 작성해주세요"
    public static let authRequestHeaderSub = "맞춤형 소비습관 형성 패턴을\n분석할 때 활용하고 있어요"
    
    public static let authRequestNickNameTitle = "닉네임"
    public static let authRequestNickNamePlaceHolder = "6자 이내로 작성해 주세요"
    public static let authRequestDuplicatedCheck = "중복검사"
    
    public static let authRequestBirthDayPlaceHolder = "생년월일을 선택해주세요 (선택)"
    public static let authRequestBirthDayTitle = "생년월일 (선택)"
    public static let authRequestBirthDayPlaceHolderYear = "YYYY"
    public static let authRequestBirthDayPlaceHolderMonth = "MM"
    public static let authRequestBirthDayPlaceHolderDay = "DD"
    
    public static let authNickNameAlreadyUse = "이미 사용중인 닉네임 입니다."
    public static let authNickNameOverOrUnderText = "2자이상 6자 이내로 작성해주세요"
    public static let authNickNameKoreanOrEnglishNotText = "닉네임은 한글, 영문 대소문자만 입력할 수 있어요"
    public static let authNickNameAllowText = "사용 가능한 닉네임 입니다."
    
    public static let authRequestGenderTitle = "성별 (선택)"
    public static let authRequestGenderMale = "남자"
    public static let authRequestGenderFemale = "여성"
    
    public static let authRequestWellComeToGoolB = "굴비잇기에 오신 걸 환영해요"
    public static let authRequestAgree = "서비스 사용전 가입 및 정보 제공에 동의해 주세요"
    public static let allAgreeText = "전체동의"
    public static let overFourTeenText = "[필수] 만 14세 이상입니다."
    public static let serviceAgreementText = "[필수] 서비스 이용약관"
    public static let privacyPolicyText = "[필수] 개인정보 보호정책"
    public static let adAgreementText = "[선택] 맞춤형 광고 및 개인정보 제공 동의"
    
    // MARK: Shopping Check List
    public static let shoppingCheckListHeaderTitle = "쇼핑중독 체크리스트"
    public static let shoppingCheckListHeaderSub = "본인이 생각하는 소비습관을"
    public static let shoppingCheckListPointText = "모두"
    public static let shoppingCheckListPointTrailingText = "선택해 주세요"
    public static let checkList1 = "스스로 통제하지 못한다"
    public static let checkList2 = "쇼핑할 때 죄책감이 든다"
    public static let checkList3 = "쇼핑할 때 긴장이나 불안감이 풀어진다"
    public static let checkList4 = "쇼핑은 필요보다 그 자체를 즐긴다"
    public static let checkList5 = "쇼핑 후 사용하지 않는 물건이 가득하다"
    public static let checkList6 = "물건을 사면 기분이 좋아진다"
    public static let checkList7 = "해당 사항 없습니다"
    
    // MARK: 소비습관 체크
    public static let ConsumptionScore = "소비 습관 점수"
    public static let ConsumptionToolTip = "평균 수입에 대한 평균 저축률을 기반으로\n소비 점수를 계산해주고 있어요"
    public static let consumptionOverconsumptionIndexMeasurement = "본인의 평균 수입과 저축으로\n과소비 지수를 측정해드려요!"
    public static let consumptionAverageMonthlyIncome = "월 평균 수입"
    public static let consumptionAverageMonthlyIncomeWrite = "₩ 월 평균 수입 금액을 작성해 주세요"
    
    public static let consumptionAverageMonthlySavings = "월 평균 저축"
    public static let consumptionAverageMonthlySavingsWrite = "₩ 월 평균 저축 금액을 작성해 주세요"
    
    public static let consumptionAverageMonthlyIncomeBigger = "월 평균 수입보다 큰 금액을 작성할 수 없습니다"
    
    // MARK: 지출 요일/시간 입력
    public static let expenditureSelectMainTitle = "지출 요일/시간 선택"
    public static let expenditureWriteYourTimeAndDay = "본인이 무슨 시간 무슨 요일에\n지출이 많은지 작성해보세요"
    public static let expenditureWeakDay = "주 지출 요일"
    public static let expenditureWeakTime = "주 지출 시간"
    public static let expenditureUsuallySelectDay = "주로 소비하는 요일을 선택해 주세요"
    
    // MARK: 분석중
    public static let analyzingConsumptionTitle = "소비유형을\n분석하고 있어요!"
    public static let analyzingConsumptionSubTitle = "조금만 기다리면,\n나의 소비 유형을 받아볼 수 있어요!"
    
    // MARK: 분석 완료
    public static let resultHabitRecommendationTitle = "나만의 맞춤형 소비습관을 추천받거나\n주변에 내 소비 유형을 공유해보세요"
    
    public static let fitMeHabitStart = "나에게 맞는 소비습관 형성하기"
    
    // MARK: 챌린지 추가
    public static let challengeTryTitle = "도전하기"
    public static let challengeAddTitle = "챌린지 추가"
    public static let challengeWhatMakeTitle = "님,\n어떤 습관을 만들어 볼까요?"
    public static let challengeChoiceWhatYouWantToHabitOne = "만들고 싶은 습관 1개를 선택해주세요"
    public static let challengeSameFamousSpendingChallenge = "같은 소비유형 인기 챌린지"
    public static let challengeHowAboutAnotherHabitOne = "그 외 이런습관은 어때요?"
    
    // MARK: 마이페이지
    public static let accountSetting = "계정 관리"
    public static let accountID = "아이디"
    public static let serviceInfo = "이용 안내"
    public static let logOut = "로그아웃"
    public static let serviceRevoke = "서비스 탈퇴"
    public static let myPage = "마이페이지"
    public static let mySpendingScoreTitle = "내 소비 점수"
    public static let totalChallengeCount = "총 챌린지 수"
    public static let writeCount = "작성한 글"
    public static let myPageConsumptionHabitsPattern = "나의 소비 습관"
    public static let myPageConsumptionHabitsPatternAnalysis = "소비습관형성 패턴 분석"
    
    // MARK: 회원 탈퇴
    public static let revokeNavigationTitle = "서비스 탈퇴"
    public static let revokeTopTitle = "다음 굴비까지 얼마 안남았는데\n정말 그만두시는건가요? :("
    public static let revokeTopSubTitle = "소중한 의견을 보내주신다면,\n더 좋은 모습으로 발전하겠습니다"
    public static let revokeFirstTitle = "앱 이용이 불편했어요"
    public static let revokeSecondTitle = "앱을 자주 사용하지 않아요"
    public static let revokeThirdTitle = "오류가 있었어요"
    public static let revokeFourthTitle = "새로운 계정을 사용하고 싶어요"
    public static let revokeFifthTitle = "기타(직접 입력)"
    
    // MARK: 살까말까
    public static let buyOrNotAddTitle = "살까말까 글 작성하기"
    public static let buyOrNotAddPhotoTitle = "사진 첨부"
    public static let buyOrNotItemNameTitle = "품목명"
    public static let buyOrNotItemNamePlaceHolder = "품목명을 작성해주세요"
    public static let buyOrNotPriceTitle = "가격"
    public static let buyOrNotPricePlaceHolder = "₩ 가격을 입력해주세요"
    public static let buyOrNotWhyBuyTitle = "사고싶은 이유"
    public static let buyOrNotWhyBuyPlaceHolder  = "20자 이내로 작성해주세요"
    public static let buyOrNotWhyNotBuyTitle = "사면 안되는 이유"
    public static let buyOrNotWhyNotBuyPlaceHolder = "20자 이내로 작성해주세요"
    
    // MARK: 그룹 챌린지
    case groupChallengeTexts(GroupChallengeTexts)
    
    public enum GroupChallengeTexts: String {
        case createGroupChallengeNavTitle = "작심삼일 방 생성하기"
        case challengeName = "챌린지명"
        case challengeNamePlaceholder = "진행할 챌린지명을 작성해주세요"
        case challengePrice = "챌린지 금액"
        case challengePricePlaceholder = "₩ 최소 1,000원~ 최대 50,000원"
        case hashTag = "해시태그"
        case hashTagPlaceholder = "한/영문,숫자로 입력해주세요"
        case maxPeopleSetting = "최대 인원 설정"
        case secretRoom = "비밀방"
        case secretRoomPassword = "비밀방 비밀번호"
        case emptyParticipatingRoom = "아직 참여한 작심삼일 방이 없어요"
        case emptyParticipatingRoomButtonText = "작심삼일 방 찾아보기"
        case onlyMakeMeShow = "내가 만든 방만 보기"
        
        case findGroupChallengePlaceholder = "챌린지명, 해시태그를 검색해보세요"
        case settingNavTitle = "작심삼일 방 설정"
        
        case onlyOneParticipantDeleteWarning = "참여자가 1명이라도 있는 경우, 삭제가 불가합니다"
        case groupChallengeDelete = "작심삼일 삭제하기"
        case groupChallengeExit = "작심삼일 나가기"
    }
    
    public var text: String {
        switch self {
        case .groupChallengeTexts(let groupChallengeTexts):
            return groupChallengeTexts.rawValue
        }
    }
}
