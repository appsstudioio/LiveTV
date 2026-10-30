# LiveTV 프로젝트 공통 작업 지침

이 문서는 모든 작업에 자동으로 포함되는 프로젝트 공통 지침이다. 코드를 추가하거나 수정하기 전에 먼저 읽고 따른다.

## 0. 필수 규칙

1. **지침 동기화**: 기능 추가·수정으로 프로젝트의 구조나 특징이 바뀌면 같은 작업 안에서 이 문서(`.kiro/steering/project-guidelines.md`)를 함께 수정한다. 아래 항목이 바뀌면 해당한다.
   - 폴더·파일 구조 (새 화면 폴더, 새 Common 파일 등)
   - 아키텍처·화면 패턴, 공통 베이스 클래스의 역할
   - 외부 의존성 (Swift Package, xcframework) 추가·삭제·교체
   - 빌드 설정 (xcconfig 키, 컴파일 조건, 스킴, 최소 지원 버전, 버전 번호)
   - Info.plist 키, 권한, 백그라운드 모드
   - 전역 컨벤션 (색상·폰트·네이밍·로그·알림 방식 등)
   - 작업을 마치기 전에 "이번 변경이 이 문서의 내용과 어긋나지 않는가"를 확인하고, 어긋나면 문서를 고친다. 변경 내용이 없으면 문서는 건드리지 않는다.
2. **기존 코드 작성 형식 준수**: 새 코드는 아래 "코드 작성 형식"을 그대로 따른다. 새 파일을 만들 때는 같은 역할의 기존 파일(예: `Views/ChannelList/`, `Views/Empty/`)을 기준으로 삼는다. 요청받지 않은 리팩터링이나 포맷 정리는 하지 않는다.
3. 사용자와의 대화·주석·UI 문구는 한국어를 사용한다.

## 1. 프로젝트 개요

- 앱 이름: LiveTV (스토어 표시명 "실시간방송"). 한국 TV·라디오 채널 목록을 보여 주고 선택한 채널의 영상 스트림을 재생하는 iOS/iPadOS 앱이다.
- 동작 방식: 서버(`BASE_URL`)의 `index.php`(TV 목록) HTML을 `WKWebView`로 로드하고, `SwiftSoup`으로 파싱해 채널 목록(`ChannelListModel`)을 만든다. 채널을 선택하면 해당 링크의 JavaScript를 웹뷰에서 실행하고, 주입한 스크립트(`metaRefreshHandler`)가 `<video>`의 URL을 전달하면 `AVPlayer`로 재생한다. Google Cast로 전송할 수도 있다.
- 언어/프레임워크: Swift 5, UIKit (코드 기반 UI, SnapKit + Then), Combine (MVVM 바인딩).
- 최소 지원: iOS 26.0 (`IPHONEOS_DEPLOYMENT_TARGET`, 타깃·프로젝트 설정 모두). iPhone·iPad 모두 지원 (`TARGETED_DEVICE_FAMILY = 1,2`). 접는 iPhone인 iPhone Duo도 지원하며, Xcode 27.1(iOS 27.1 SDK)의 iPhone Duo 시뮬레이터로 확인한다. UI는 iOS 26 Liquid Glass 디자인을 따른다(6.4 참고).
- 저장소: `appsstudioio/LiveTV` (GitHub). 브랜치는 `main`, `develop`, `feature/*` 형태로 사용해 왔다.

## 2. 디렉터리 구조

`LiveTV.xcodeproj`는 **파일 시스템 동기화 그룹**(`PBXFileSystemSynchronizedRootGroup`)을 사용한다. `LiveTV/` 아래에 파일을 만들면 타깃에 자동 포함되므로 `project.pbxproj`를 직접 수정하지 않는다. 예외는 `Info.plist`와 xcconfig 두 개(타깃 멤버십 제외)이다. 서드파티 바이너리는 폴더에 직접 넣지 않고 Swift Package로 추가한다.

```
LiveTV/
├── AppDelegate.swift            # @main. Firebase, Kingfisher, ProgressHUD, GoogleCast 초기화
├── SceneDelegate.swift          # 모든 기기: MainSplitViewController (좁으면 한 칸으로 접힘)
├── Common/
│   ├── BaseControllers/         # BaseViewController(+Extension), BaseNavigationController, BaseWebViewController
│   ├── BaseModel/               # BaseModel.swift (공통 응답 모델, NotificationList)
│   ├── BaseViewModel/           # BaseViewModel, BaseWebViewModel
│   ├── Extensions/              # UIKit 확장 (UIViewController, UIImageView, UINavigationBar 등)
│   └── Functions/               # CommonFunctions.swift (DLog, 모듈 @_exported import, SDK 설정)
├── Configurations/
│   ├── GoogleService-Info.plist
│   └── xcconfig/                # Develop.xcconfig(Debug), Release.xcconfig(Release)
├── Network/                     # BaseHostUrlDefine.swift (호스트·경로 정의)
├── Resources/
│   ├── Assets.xcassets          # 앱 아이콘, 이미지
│   ├── Color/                   # Colors.xcassets + ComponentColor.swift
│   ├── Font/                    # ComponentFont.swift, ComponentFont+Extension.swift
│   ├── Base.lproj/LaunchScreen.storyboard, ko.lproj/
│   ├── Info.plist, PrivacyInfo.xcprivacy
└── Views/
    ├── ChannelList/             # 채널 목록. 검색은 Controller의 navigationItem.searchController. Controller / Model / View / ViewModel
    ├── VideoPlayer/             # 영상 재생(AVPlayer, Cast). Controller / Model / ViewModel
    ├── MainSplit/               # 앱 루트 UISplitViewController (펼침: 목록 | 상세, 접힘: 목록 → push). 접힘·펼침 때 재생 화면을 옮긴다. 목록 칼럼 폭은 20%, 최소 280pt(검색 플레이스홀더가 잘리지 않게), 최대 40%
    ├── Empty/                   # 펼친 화면 상세 영역의 "채널을 선택하세요" 화면
    └── CommonViews/             # 재사용 뷰 (ToastView)
```

### 새 화면 추가 규칙

`Views/<화면명>/` 아래에 필요한 하위 폴더만 만든다.

| 폴더 | 파일명 | 비고 |
| --- | --- | --- |
| `Controller/` | `<화면명>ViewController.swift` | `final class`, `BaseViewController` 상속 |
| `View/` | `<화면명>View.swift`, `<화면명>Cell.swift` | 레이아웃 전담 `UIView`, `final class` |
| `ViewModel/` | `<화면명>ViewModel.swift` | `BaseViewModel` 상속 (상태가 단순하면 일반 `final class`도 가능, `VideoPlayerViewModel` 참고) |
| `Model/` | `<화면명>Model.swift` | `struct`와 화면 전용 `enum` |

여러 화면이 쓰는 코드는 `Common/`(로직·확장·베이스) 또는 `Views/CommonViews/`(뷰)에 둔다.

## 3. 아키텍처

- **MVVM + Combine**. ViewController는 `viewModel`과 `subViews`(레이아웃 전담 View)를 프로퍼티로 가진다.
  - `View`: 서브뷰 생성, SnapKit 레이아웃, 스타일만 담당한다. 비즈니스 로직을 넣지 않는다.
  - `ViewModel`: 데이터 보유, 변환, 검색·파싱 등 로직. UIKit 뷰를 직접 참조하지 않는다. ViewController에는 `state`의 `PassthroughSubject`로 알린다.
  - `ViewController`: 바인딩(`setBinding()`), UI 구성(`setupUI()`), 델리게이트 구현.
- ViewModel 구조 (`ChannelListViewModel` 기준)
  - `struct Action`(View → ViewModel 입력), `struct State`(ViewModel → View 출력)을 중첩 선언하고 `var action`, `var state`로 보유한다. 사용하지 않는 `Action`은 주석 처리된 채로 두는 기존 방식이 있으나, 새 코드에서는 필요한 것만 선언한다.
  - 구독 해제는 `cancellables: Set<AnyCancellable>`에 `store(in:)`로 한다. 셀은 `prepareForReuse()`에서 초기화한다.
- **접힘 / 펼침 분기 (iPhone Duo 대응)**: 기기 종류(`userInterfaceIdiom`)로 레이아웃을 고르지 않는다. iPhone Duo는 사용 중에 접고 펴면서 창 크기와 size class가 바뀌고, 펼친 iPhone도 regular 폭이 된다(Apple [Three steps to make your app shine on iPhone Duo](https://developer.apple.com/iphone-duo/prepare/)).
  - 루트는 모든 기기에서 `MainSplitViewController`다. 기준은 `splitViewController?.isCollapsed`(없으면 접힘으로 본다).
  - 접힘(한 칸): 목록은 카드형 그리드, 채널 선택 시 목록 네비게이션에 `VideoPlayerViewController`를 `push`한다. 재생 화면은 네비게이션 루트가 아니면 직접 만든 뒤로 버튼을 쓴다.
  - 펼침(두 칸): 목록은 한 줄 목록형, 채널 선택 시 `NotificationList.showChannelLoad` 알림을 `MainSplitViewController`가 받아 secondary 영역을 교체한다.
  - 접힘·펼침 전환은 `MainSplitViewController`의 `splitViewControllerDidCollapse`/`DidExpand`에서 처리한다. 보던 채널의 재생 화면을 새로 만들어 반대쪽(push ↔ secondary)으로 옮기고, `ChannelListViewController.updateLayoutStyle()`을 부른다. 접힐 때 상세를 목록 위에 자동으로 합치지 않도록 `topColumnForCollapsingToProposedTopColumn`은 `.primary`를 반환한다.
  - 크기에 따른 레이아웃은 시작할 때 한 번이 아니라 `viewDidLayoutSubviews`(또는 `viewWillTransition(to:with:)`)에서 매번 다시 계산한다. 크기는 `view.bounds`, safe area는 `view.safeAreaInsets`나 `safeAreaLayoutGuide`에서 읽고 `UIApplication.shared.safeAreaInsets`나 기기 방향(`UIDevice.current.orientation`, `interfaceOrientation`), 특정 화면 크기 비교를 쓰지 않는다.
  - iOS 27.1 SDK에서는 iPhone Duo의 툴바가 화면 옆에 세로로 붙는다. 세로 스크롤 목록은 좌우 safe area를 섹션 여백에 더한다(`ChannelListViewController`의 `insetForSectionAt`).
  - 액션 시트는 넓은 화면에서 팝오버가 되므로 기기와 관계없이 `popoverPresentationController`의 기준 뷰(또는 `sourceItem`)를 지정한다.
  - 화면을 추가·수정할 때는 일반 iPhone, iPad, iPhone Duo(접힘·펼침, 재생 중 전환) 동작을 모두 확인한다.
- **화면 간 통지**: `Common/BaseModel/BaseModel.swift`의 `NotificationList` enum에 case와 `name`을 추가해서 사용한다. 문자열 이름을 직접 쓰지 않는다.
- **API/호스트**: URL은 `Network/BaseHostUrlDefine.swift`의 `BaseUrlPathDefine`에 case를 추가하고 `url`에서 반환한다. 호스트는 `Info.plist`의 `BaseURL`(= xcconfig `BASE_URL`)에서 읽는다. 현재 Moya/Alamofire를 쓰지 않고 `WKWebView`와 `URLSession`을 직접 사용한다.
- **웹뷰**: 모바일 User-Agent를 고정해서 쓰고(`customUserAgent`), 쿠키는 `HTTPCookieStorage` → `WKHTTPCookieStore`로 동기화한다. DEVELOP 빌드에서만 `isInspectable = true`를 켠다.
- **오디오**: 재생 화면에서는 `setAudioSessionActive(true)`로 세션을 켜고 `viewDidDisappear`에서 끈다(전체 화면 모달이 덮은 경우는 제외). `AVAudioSession`의 `setCategory`·`setActive`는 블로킹 호출이므로 메인 스레드에서 부르지 않는다. `setAudioSessionActive`는 `BaseViewController+Extension.swift`의 전용 직렬 큐(`audioSessionQueue`)에서 실행하며, 오디오 세션 작업을 추가할 때도 이 큐를 쓴다. 오류는 `try?`로 버리지 않고 `DLog(level: .error)`로 남긴다. `Info.plist`의 `UIBackgroundModes = audio`, `NSBonjourServices`(`_googlecast._tcp`, `_CC1AD845._googlecast._tcp`)에 의존한다. 두 번째 값은 기본 수신 앱 ID(`kGCKDefaultMediaReceiverApplicationID` = `CC1AD845`)로, 수신 앱 ID를 바꾸면 함께 바꾼다.
- **Cast**: 미디어 로드는 `remoteMediaClient.loadMedia(with: GCKMediaLoadRequestData)`를 쓴다(`loadMedia(_:)`과 `autoplay` 변형은 비권장·deprecated). `GCKRequestDelegate.request(_:didFailWithError:)`에서 `GCKErrorCode.cancelled`(사용자가 Cast 이용약관 거부 등)는 자동 재시도하지 않는다. `VideoPlayerViewController`는 `GCKSessionManagerListener`로 등록되어(`sessionManager.add(self)`, `deinit`에서 `remove(self)`) 연결이 끝나면(`didStart`) 기기 재생을 멈추고 현재 채널을 바로 전송한다. SDK는 리스너를 약하게 보유하므로 등록한 객체는 반드시 해제 시 제거한다.

## 4. 빌드 구성과 설정

| 구분 | Debug | Release |
| --- | --- | --- |
| xcconfig | `Develop.xcconfig` | `Release.xcconfig` |
| 스킴 | `LiveTV-Dev` | `LiveTV` |
| 컴파일 조건 | `DEVELOP DEBUG` | `RELEASE` |
| 앱 표시명 | LiveTV | 실시간방송 |
| `APPSTORE_ID` | 6473762430 | 1352848474 |
| App Group | `group.io.appstudio.LiveTV.dev` | `group.io.appstudio.LiveTV` |

- Bundle ID(`io.appstudio.LiveTV`), `MARKETING_VERSION`(현재 1.0.5), `CURRENT_PROJECT_VERSION`은 두 xcconfig에 각각 있다. **버전을 올릴 때는 두 파일을 같이 수정한다.**
- 앱 타깃에는 `LM_FORCE_LINK_GENERATION = YES`가 있다. App Intents를 쓰지 않는 앱에서 나는 `Metadata extraction skipped, no AppIntents.framework dependency found` 워닝을 없애려는 설정이다(Swift 패키지 타깃과 같은 방식). App Intents를 도입해도 그대로 둬도 된다.
- iOS 26 타깃에서 deprecated 워닝이 나지 않도록 `UIScreen.main` 대신 `view.bounds`나 `view.window?.windowScene?.screen`을, `traitCollectionDidChange` 대신 `registerForTraitChanges`를 쓴다.
- 환경별 값(호스트, Firebase 파일명, 스토어 ID 등)은 xcconfig 키로 추가하고 `Info.plist`에 `$(KEY)`로 노출한 뒤 `Bundle.getInfoPlistValue(forKey:)`로 읽는다. 코드에 하드코딩하지 않는다.
- xcconfig의 URL은 `//`가 주석으로 해석되므로 `http:\/\/host` 형태로 이스케이프한다.
- `GoogleService-Info.plist`, 서명·키 값은 임의로 변경·출력하지 않는다.
- Crashlytics 수집은 기본 비활성(`setCrashlyticsCollectionEnabled(false)`)이다. 사용자 동의 흐름 없이 활성화하지 않는다.
- `Info.plist`에는 `NSAllowsArbitraryLoads = true`가 있다(서버가 `http`). 이 설정과 `PrivacyInfo.xcprivacy`를 변경해야 하는 작업은 사용자에게 먼저 확인한다.

## 5. 외부 의존성

Swift Package Manager로 관리한다. 해석된 버전은 `LiveTV.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`에 있다.

| 패키지 | 용도 |
| --- | --- |
| `CommonUtils` (appsstudioio, 자체 라이브러리) | `DebugLog`, `HangeulSearch`, `.identifier`, `.localization`, `pushView`/`presentView`/`moveBack`, `tapPublisher`/`textPublisher`/`keyboardHeight()`, `CommonUtils.getAppName`, `Bundle.getInfoPlistValue` 등 공통 헬퍼 |
| SnapKit, Then | 오토레이아웃, 선언형 초기화 |
| Kingfisher, ProgressHUD, SwiftSoup | 이미지 캐시, 로딩 HUD, HTML 파싱 |
| Firebase 12.x (Analytics, Crashlytics, Performance, AppDistribution) | 분석·크래시·성능. **13으로 올리지 않는다** (아래 참고) |
| Moya, Alamofire, RxSwift, ReactiveSwift | 의존성에 포함되어 있으나 현재 코드에서 사용하지 않음. 새 코드에 도입하지 않는다 |
| LookinServer | UI 디버깅용 |
| Google Cast SDK 4.8.x (`google-cast-ios-sdk`, `GoogleCastDynamic` 제품) | Chromecast 전송. 동적 프레임워크라 Xcode가 자동으로 Embed한다. `import GoogleCast` |

- **Firebase 버전 고정 이유**: `google-cast-ios-sdk` 4.8.6은 `gtm-session-fetcher` 3.x만 허용하고, Firebase 13은 4.0.0 이상을 요구해 패키지 해석이 실패한다. Firebase 12.x(`gtm-session-fetcher` 3.4.1..<6.0.0)는 두 조건을 함께 만족하므로 Firebase는 `12.19.3`부터 다음 메이저 전까지(upToNextMajor)로 둔다. Cast 패키지가 `gtm-session-fetcher` 4.x 이상을 허용하는 버전을 내면 Firebase를 13으로 올릴 수 있다.

- 위 `CommonUtils` 헬퍼들은 이 프로젝트 소스 어디에도 정의되어 있지 않아 외부 패키지에서 제공되는 것으로 판단했다(패키지 소스는 로컬에서 확인하지 못했다). 정확한 시그니처가 필요하면 Xcode의 Package Dependencies에서 `CommonUtils` 소스를 열어 확인하고, 임의로 같은 이름의 확장을 프로젝트에 중복 정의하지 않는다.
- 헬퍼가 필요하면 먼저 `CommonUtils`와 `Common/` 안에 있는지 확인하고, 있으면 재사용한다.
- 공통 모듈은 `CommonFunctions.swift`에서 `@_exported import`로 전역 공개한다(Combine, CommonUtils, SnapKit, Then, Kingfisher, ProgressHUD, Network, SwiftSoup). 이 모듈들은 파일마다 다시 import하지 않아도 되지만, 기존 파일처럼 UI 파일은 `import UIKit`, `SnapKit`, `Then`, `Combine`을 명시한다.
- 의존성을 추가·제거하면 이 표와 5장 설명을 갱신한다.

## 6. 코드 작성 형식

### 6.1 파일 헤더

모든 Swift 파일은 Xcode 기본 헤더를 사용한다. 작성자와 날짜 형식은 최근 파일을 따른다.

```swift
//
//  ChannelListCell.swift
//  LiveTV
//
//  Created by 10-N3344 on 10/18/24.
//

import UIKit
```

- 날짜는 `M/d/yy` (예: `10/24/24`). 파일명은 헤더와 실제 파일명이 일치해야 한다.
- import는 헤더 아래 한 줄을 띄우고 시스템 프레임워크 → 서드파티 순으로 적는다. WebKit은 `@preconcurrency import WebKit`을 사용한다.

### 6.2 네이밍

- 타입: UpperCamelCase. 접미사로 역할을 드러낸다: `…ViewController`, `…View`, `…Cell`, `…ViewModel`, `…Model`.
- 프로퍼티·함수: lowerCamelCase. 바인딩은 `setBinding()`, UI 구성은 `setupUI()`, 셀 갱신은 `updateUI(...)`, 뷰모델 입력은 `set…`/`change…` 동사로 시작한다.
- 확장 파일: `<타입명>+Extension.swift` (예: `BaseViewController+Extension.swift`).
- 색상 이름: `ComponentColor`의 case 이름과 `Colors.xcassets` 이름이 일치해야 한다.

### 6.3 클래스 구성 순서

화면 클래스는 아래 순서와 `// MARK:` 구분을 따른다.

1. `let subViews = …View()`, `let viewModel = …ViewModel()`, 그 외 프로퍼티
2. `init`(필요한 경우), `required init?(coder:)`는 `fatalError("init(coder:) has not been implemented")`
3. 라이프사이클: `loadView()` → `// MARK: - viewDidLoad()` → `viewDidLoad` → `viewWillAppear` → `viewIsAppearing` → `viewDidAppear` → `viewWillDisappear` → `viewDidDisappear` → `hidesBottomBarWhenPushed` → `traitCollectionDidChange`
4. `// MARK: - functions` : `private func setBinding()`, `private func setupUI()` 등
5. `// MARK: - extensions` 또는 `// MARK: - <프로토콜명>` 블록: 델리게이트·데이터소스는 클래스 본문이 아니라 `extension ClassName: Protocol`로 분리한다.

```swift
final class ChannelListViewController: BaseViewController {

    let subViews = ChannelListView()
    let viewModel = ChannelListViewModel()

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setBinding()
    }

    // MARK: - functions
    private func setBinding() {
        viewModel.state.updateUI.sink { [weak self] _ in
            self?.subViews.collectionView.reloadData()
        }.store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDelegate
extension ChannelListViewController: UICollectionViewDelegate { … }
```

### 6.4 UI 코드

- 코드 기반 UI만 사용한다(Storyboard는 `LaunchScreen`만). 서브뷰는 `Then`으로 선언하고 `setupUI()`에서 `addSubview` + `snp.makeConstraints`를 한다. 여러 뷰를 추가할 때는 `[a, b].forEach { addSubview($0) }`를 쓴다.
- 색상: `UIColor.named(.contentPrimary)` 또는 `.named(...)`만 사용한다. 새 색상은 `Colors.xcassets`에 colorset을 추가하고 `ComponentColor`에 case를 추가한다. `UIColor(red:…)`나 hex 리터럴을 직접 쓰지 않는다(`progressHUDConfig` 예외 외).
- 폰트·텍스트: `"문구".toAttributed(fontType: .sb15px, color: .named(.contentSecondary), alignment: .center)`로 `attributedText`에 설정한다. 폰트는 `ComponentFont`(`r`=regular, `sb`=semibold, `b`=bold + 크기 `08px…34px`)에서 고르고 `UIFont.systemFont`를 직접 쓰지 않는다.
- 셀 재사용 식별자는 `Cell.identifier`(CommonUtils)를 쓴다.
- 레이아웃이 화면 크기에 따라 다르면 기기 종류가 아니라 split view 접힘 상태, size class, 사용 가능한 폭으로 분기한다(3장 "접힘 / 펼침 분기" 참고).
- 사용자에게 보이는 알림은 `alertWith`, `alertConfirmWith`(UIViewController 확장), 토스트는 `ToastView.show(.error, message:)`, 로딩은 `showLoading`/`hideLoading` 또는 `ProgressHUD`를 사용한다.

### 6.4.1 Liquid Glass (iOS 26)

시스템 바와 컨트롤은 별도 코드 없이 Liquid Glass가 적용된다. 아래 커스텀은 그 효과를 지우므로 쓰지 않는다.

- **네비게이션 바**: 배경을 지정하지 않는다. `BaseNavigationController`가 호출하는 `UINavigationBar.setDefaultNavigationBarStyle()`(프로젝트 확장)은 `configureWithDefaultBackground()`에 타이틀 글꼴·색상만 지정한다. CommonUtils의 `setNavigationBarStyle(_:fontColor:font:largeFont:)`와 그것을 감싼 `UIViewController.setNavigationBarStyle`은 불투명 배경을 쓰므로 호출하지 않는다. `barTintColor`, `backgroundColor`, `configureWithOpaqueBackground()`도 쓰지 않는다.
- **바 버튼**: 이미지·텍스트 버튼은 `UIBarButtonItem(image:style:target:action:)` 같은 기본 항목으로 만든다. 탭 처리는 CommonUtils의 `UIBarButtonItem.tapPublisher`를 쓴다. CommonUtils의 `createUIBarButtonItem`(흰색 아이콘 customView), `buttonToBarButtonItem`, `hideNavigationLeftButton(hidden:button:buttonSize:)`처럼 고정 크기 `UIButton`을 customView로 넣는 방식은 쓰지 않는다. customView는 SDK가 그리는 버튼(`GCKUICastButton`)처럼 대체할 수 없는 경우에만 `UIBarButtonItem(customView:)`로 쓴다.
- **검색**: `UISearchBar`를 화면에 직접 넣지 않고 `UISearchController`를 `navigationItem.searchController`에 둔다(`ChannelListViewController` 참고). 검색 필드의 배경·테두리·`value(forKey: "searchField")` 접근 같은 커스텀은 하지 않는다. 위치는 시스템 기본값(iPhone 하단 툴바 영역)을 따르고, 바꿀 때는 `preferredSearchBarPlacement`를 쓴다. 검색 시작·종료 처리는 `UISearchControllerDelegate`(`willPresent`/`willDismissSearchController`)에서 한다.
- **스크롤 콘텐츠**: 목록은 상단을 safe area가 아닌 view에 맞춰 바 아래로 스크롤되게 하고 여백은 `contentInsetAdjustmentBehavior`(기본값)에 맡긴다. 한 화면에 스크롤 뷰가 여러 개면(예: 숨겨진 `WKWebView`) `setContentScrollView(_:for:)`로 바가 따라갈 스크롤 뷰를 지정한다. 당겨서 새로고침은 `collectionView.refreshControl`에 넣는다.
- **스크롤하지 않는 콘텐츠**: 스크롤 엣지 효과가 없는 뷰는 기본적으로 상단을 `safeAreaLayoutGuide`에 맞춘다(투명한 바 아래 어두운 콘텐츠 위에서 타이틀이 보이지 않는 문제 방지). 예외로 재생 화면(`VideoPlayerViewController`)은 영상을 바 아래까지 채운다(위아래는 `equalToSuperview()`). 좌우는 `safeAreaLayoutGuide`에 맞춘다. iOS 26 split view는 상세 칼럼을 목록 칼럼 밑까지 깔고 그 폭을 safe area로 비우므로, 좌우를 화면 끝에 맞추면 콘텐츠가 목록에 가려진다. 대신 그 화면의 `navigationItem`에 `configureWithTransparentBackground()` + 흰색(`contentWhite`) 타이틀 appearance를 지정하고, `preferredStatusBarStyle = .lightContent`를 쓴다(`BaseNavigationController`·`MainSplitViewController`(접힘일 때)의 `childForStatusBarStyle`이 따른다). 바 배경색은 지정하지 않는다.
- **영상 전체 화면**: 재생 화면 바의 전체 화면 버튼은 새 `AVPlayerViewController`를 `.fullScreen` 모달로 띄우고 같은 `AVPlayer`를 옮겨 붙인다(화면 안 플레이어에서는 뗀다). 돌아오면 `viewIsAppearing`에서 다시 붙인다. 모달이 덮은 동안에는 `viewDidDisappear`에서 재생·오디오 세션을 멈추지 않는다. iPhone Duo를 접거나 펴서 재생 화면을 옮기기 전에는 `dismissFullScreenPlayer`로 모달을 먼저 닫는다.
- **떠 있는 버튼**: 콘텐츠 위에 떠 있는 버튼은 흰 배경·그림자 대신 `UIButton.Configuration.glass()`(강조는 `.prominentGlass()`)를 쓴다. 커스텀 뷰에 유리 효과가 필요하면 `UIVisualEffectView(effect: UIGlassEffect())`를 쓴다.
- **팝오버·액션 시트**: 바 버튼에서 띄울 때 `popoverPresentationController?.sourceItem`에 그 버튼을 지정한다.
- 목록 셀 같은 콘텐츠에는 Liquid Glass를 쓰지 않는다. `Info.plist`에 `UIDesignRequiresCompatibility`를 추가하지 않는다.

### 6.5 Swift 스타일

- 들여쓰기는 스페이스 4칸. 중괄호는 같은 줄에서 연다. 파일 끝은 개행으로 끝낸다.
- 클로저에서 `self` 캡처는 `[weak self]` + `guard let self = self else { return }`(또는 `self?.`) 패턴을 쓴다.
- 구독은 `.sink { … }.store(in: &cancellables)` 형태로 쓴다.
- 접근 제어: 외부에서 쓰지 않는 함수는 `private`. 화면 클래스는 `final`. 상속이 필요한 베이스만 `class`/`public class`로 둔다.
- `guard`로 조기 반환한다. 인덱스 접근 전에는 `guard list.count > indexPath.item else { return … }`처럼 범위를 확인한다.
- 강제 언래핑(`!`)과 `try!`는 새로 추가하지 않는다. 기존의 `as! ChannelListCell` 같은 셀 캐스팅은 관례이므로 새 셀에서만 동일하게 써도 된다.
- 문자열 리터럴 UI 문구는 한국어로 쓴다. 이미 `"cancel".localization`처럼 키를 쓰는 곳은 그 방식을 유지한다.
- iOS 26 이상이 최소 버전이므로 iOS 26 API는 `#available` 없이 바로 쓰고, 26 이하 버전 분기를 새로 추가하지 않는다. 26 초과 API에만 분기를 둔다. 기존 코드의 `#available(iOS 12/15/16.4/18, *)` 분기는 항상 참이며, 해당 코드를 수정할 때 함께 정리한다.
- 주석은 한국어, `//` 한 줄 주석을 사용하며 "왜"를 설명한다. 사용하지 않는 코드는 새로 주석으로 남기지 않는다.

### 6.6 로그

- `print`를 쓰지 않고 `DLog(_:level:)`을 사용한다. 레벨은 `.info`(기본), `.debug`, `.error`.
- `DLog`는 `DEBUG` 빌드에서만 출력한다. 개인정보·쿠키·토큰을 로그로 남기지 않는다.
- 분석용 화면 로그는 `viewDidAppear`에 주석으로 남아 있는 `AnalyticsManager.setScreenName` 형식을 참고한다(현재 비활성).

## 7. 작업 절차

1. 요청 범위를 파악하고, 영향받는 화면(iPhone/iPad/iPhone Duo 접힘·펼침)과 공통 코드를 확인한다.
2. 같은 역할의 기존 파일을 열어 형식을 맞춘 뒤 구현한다. 공통 헬퍼가 있으면 재사용한다.
3. 새 파일은 위 구조 규칙에 맞는 폴더에 만든다. 파일 시스템 동기화 그룹이므로 `project.pbxproj`는 수정하지 않는다.
4. 빌드 설정·의존성·Info.plist를 건드렸다면 4·5장을 갱신한다.
5. 구조나 특징이 달라졌다면 이 문서를 수정한다(0장 1번).
6. 빌드 확인이 필요하면 사용자의 Xcode 환경을 기준으로 안내한다. 예: `xcodebuild -project LiveTV.xcodeproj -scheme LiveTV-Dev -destination 'generic/platform=iOS Simulator' build`. 요청이 없으면 테스트 코드를 추가하지 않는다(현재 테스트 타깃 없음).
7. 커밋 메시지는 기존 이력처럼 날짜와 작업 내용을 짧은 한국어로 적는다(예: `2024.10.25 ipad UI 추가.`). 사용자가 요청하기 전에는 커밋하지 않는다.

## 8. 알려진 특이사항 (수정 요청이 없으면 그대로 둔다)

- `ChannelListViewController`와 `ChannelListView`가 각각 `WKWebView`를 만든다. 목록은 화면 뒤에 깔린 웹뷰의 HTML에서 얻으므로 웹뷰를 제거하거나 숨김 해제하지 않는다.
- `BaseUrlPathDefine.radioList`는 정의만 있고 사용하지 않는다.
- `SceneDelegate`에 `sleep(1)`이 있다(런치 화면 노출용).
- `BaseWebViewController`(진입점인 `showWebView`는 호출처가 없다)와 `UIViewController+Extension`의 카메라·사진 선택 함수처럼, 현재 화면에서 호출하지 않는 공통 코드가 있다. 삭제 요청이 없으면 그대로 둔다.
- `Base.lproj`(앱 루트)는 비어 있고, 런치 화면은 `Resources/Base.lproj`에 있다.
