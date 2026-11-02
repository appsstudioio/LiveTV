# LiveTV (실시간방송)

한국 TV·라디오 채널 목록을 보여 주고, 고른 채널의 실시간 방송을 재생하는 iOS / iPadOS 앱입니다.

- 스토어 표시명: **실시간방송**
- 지원 기기: iPhone, iPad, iPhone Duo(접는 iPhone)
- 최소 지원: iOS 26.0 (Liquid Glass 디자인)

## 주요 기능

| 기능 | 설명 |
| --- | --- |
| 채널 목록 | 서버의 채널 목록 페이지를 불러와 채널을 보여 줍니다. 당겨서 새로고침을 지원합니다. |
| 채널 검색 | 상단(iPhone은 하단) 검색창에서 채널명으로 찾습니다. |
| 실시간 재생 | `AVPlayer`로 재생합니다. 백그라운드 오디오, PiP, AirPlay를 지원합니다. |
| 전체 화면 | 재생 화면 바의 전체 화면 버튼으로 시스템 전체 화면 플레이어를 띄웁니다. |
| Google Cast | Chromecast 기기로 보고 있는 채널을 보냅니다. |
| 편성표 | 재생 중인 채널의 편성표를 Safari 화면으로 엽니다. |
| 화면 크기 대응 | 좁은 화면은 카드형 목록 → 재생 화면 이동, 넓은 화면은 목록 \| 재생 두 칸으로 보여 줍니다. iPhone Duo를 접고 펴면 보던 채널을 이어서 보여 줍니다. |

## 동작 방식

```
채널 목록 HTML(WKWebView) → SwiftSoup 파싱 → 채널 목록
채널 선택 → 링크의 JavaScript 실행 → 주입 스크립트가 <video> URL 전달 → AVPlayer 재생 / Cast 전송
```

## 개발 환경

| 항목 | 값 |
| --- | --- |
| Xcode | 27.1 이상 (iOS 27.1 SDK, iPhone Duo 시뮬레이터 포함) |
| 언어 | Swift 5 |
| UI | UIKit 코드 기반 (SnapKit, Then) |
| 구조 | MVVM + Combine |
| 패키지 관리 | Swift Package Manager |

## 빌드

```bash
git clone https://github.com/appsstudioio/LiveTV.git
cd LiveTV
open LiveTV.xcodeproj
```

Xcode가 Swift 패키지를 자동으로 받습니다. 스킴을 고른 뒤 실행합니다.

| 구분 | Debug | Release |
| --- | --- | --- |
| 스킴 | `LiveTV-Dev` | `LiveTV` |
| 설정 파일 | `Develop.xcconfig` | `Release.xcconfig` |
| 컴파일 조건 | `DEVELOP DEBUG` | `RELEASE` |
| 앱 표시명 | LiveTV | 실시간방송 |

명령줄 빌드 예:

```bash
xcodebuild -project LiveTV.xcodeproj -scheme LiveTV-Dev \
  -destination 'platform=iOS Simulator,name=iPhone Duo' build
```

서버 주소(`BASE_URL`)와 스토어 ID 같은 환경별 값은 `LiveTV/Configurations/xcconfig/`의 xcconfig 파일에 있고, `Info.plist`를 거쳐 코드에서 읽습니다.

## 프로젝트 구조

```
LiveTV/
├── AppDelegate.swift          # Firebase, Kingfisher, ProgressHUD, Google Cast 초기화
├── SceneDelegate.swift        # 루트: MainSplitViewController
├── Common/                    # 베이스 클래스, 공통 모델, UIKit 확장, 공통 함수
├── Configurations/            # GoogleService-Info.plist, xcconfig
├── Network/                   # 호스트·경로 정의
├── Resources/                 # 에셋, 색상, 폰트, Info.plist, 런치 화면
└── Views/
    ├── ChannelList/           # 채널 목록·검색
    ├── VideoPlayer/           # 영상 재생, Cast, 전체 화면
    ├── MainSplit/             # 목록 | 재생 split view (좁으면 한 칸으로 접힘)
    ├── Empty/                 # "채널을 선택하세요" 화면
    └── CommonViews/           # ToastView 등 공통 뷰
```

코드 작성 규칙은 [`.kiro/steering/project-guidelines.md`](.kiro/steering/project-guidelines.md)에 있습니다.

## 주요 의존성

| 패키지 | 용도 |
| --- | --- |
| CommonUtils | 공통 헬퍼 (자체 라이브러리) |
| SnapKit, Then | 오토레이아웃, 선언형 초기화 |
| Kingfisher | 이미지 캐시 |
| ProgressHUD | 로딩 표시 |
| SwiftSoup | HTML 파싱 |
| Firebase 12.x | Analytics, Crashlytics, Performance |
| Google Cast SDK 4.8.x | Chromecast 전송 |
| LookinServer | UI 디버깅 |

## 브랜치와 배포 흐름

```
feature/* ──PR──▶ develop ──PR──▶ main ──태그(1.0.6)──▶ GitHub 릴리즈
fix/*     ──PR──▶ develop
hotfix/*  ──PR──▶ main
```

GitHub Actions가 다음을 자동으로 합니다.

| 워크플로 | 실행 시점 | 하는 일 |
| --- | --- | --- |
| [PR 자동 생성](.github/workflows/auto-pr.yml) | `feature/*`, `fix/*`, `hotfix/*`, `develop` push | 대상 브랜치로 PR을 만들고 라벨을 붙입니다. 열린 PR이 있으면 건너뜁니다. |
| [릴리즈 노트 생성](.github/workflows/release.yml) | 버전 태그 push, 또는 Actions에서 직접 실행 | GitHub 릴리즈를 만들고 이전 태그 이후 머지된 PR로 노트를 채웁니다. |

릴리즈 노트는 PR 라벨로 묶입니다([`.github/release.yml`](.github/release.yml)).

| 라벨 | 노트 분류 | 붙는 브랜치 |
| --- | --- | --- |
| `enhancement` | 새 기능 | `feature/*` |
| `bug` | 버그 수정 | `fix/*`, `hotfix/*` |
| `documentation` | 문서 | 직접 지정 |
| `release` | 노트에서 제외 | `develop` → `main` |

### 릴리즈 하는 법

1. `Develop.xcconfig`, `Release.xcconfig`의 `MARKETING_VERSION`을 함께 올립니다.
2. `develop`을 push하면 `main`으로 가는 릴리즈 PR이 생깁니다. 확인 후 머지합니다.
3. 아래 둘 중 하나로 릴리즈를 만듭니다.
   - 태그 push: `git tag 1.0.6 && git push origin 1.0.6`
   - Actions → **릴리즈 노트 생성** → Run workflow (버전을 비우면 `Release.xcconfig` 값 사용)

### 처음 한 번 설정

PR 자동 생성은 저장소 설정을 켜야 동작합니다.

Settings → Actions → General → Workflow permissions → **Allow GitHub Actions to create and approve pull requests** 체크

## 라이선스

[Apache License 2.0](LICENSE)
