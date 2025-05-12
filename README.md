# 🥷📸 poporazzi 포포라치
> 여행 다녀와서 사진 정리하는게 너무 귀찮은 나! (개발자 본인 이야기입니다.) 이젠 좀 쉽게 사진 정리하자,,,!

|상태|앱스토어 배포 완료 및 업데이트 진행 중(v1.4.2)|
|:--|:--|
|기술 스택|UIKit, RxSwift, FlexLayout, PinLayout, PhotoKit, Xcode Cloud|
|Link|[AppStore](https://apps.apple.com/kr/app/%ED%8F%AC%ED%8F%AC%EB%9D%BC%EC%B9%98/id6744402068), [Figma](https://www.figma.com/design/4uudfkvUr18HbnBhyKSTro/%ED%8F%AC%ED%8F%AC%EB%9D%BC%EC%B9%98?node-id=57-364&p=f&t=5ZyurDKbkj51pwCl-11), [Instagram](https://www.instagram.com/poporazzzzzi?igsh=MWV1cDl4ZWU2b2p0bQ%3D%3D&utm_source=qr)|
|이메일 문의|eunlyuing@gmail.com|

### 완전 쉬운 포포라치 3️⃣단계 이용법
1. 여행 전 기록 시작하기 버튼 꾹 눌러놓기.
2. 내맘대로 여행 즐기며 마음껏 사진 찍기.
3. 여행 다녀온 후 종료 버튼 눌러 앨범으로 쏙 저장하기!

![Group 1](https://github.com/user-attachments/assets/b2904b2f-4c41-49b2-9de4-7e50cd7a5eff)

### 🛠️ 개발 타임라인

#### v1.0.0 / 25.04.04 ~ 25.04.10 
> 포포라치 프로젝트의 첫 시작! MVP 모델로 최대한 빠르게 개발

|PR 제목|주요 구현 내용|
|:--|:--|
|[#3 Xcode 기본 세팅 및 라이브러리 추가](https://github.com/thinkySide/poporazzi/pull/3)|Miminum Target 16.0 설정, Code Base UI 세팅, PinLayout, FlexLayout, RxSwift, RXCocoa 라이브러리 추가|
|[#5 MomentTitleInput 화면 구현](https://github.com/thinkySide/poporazzi/pull/5)|CodeBaseUIView Protocol 구현, MomoentTitleInputView 구현|
|[#7 디자인 리소스 추가](https://github.com/thinkySide/poporazzi/pull/7)|Pretendard 폰트 파일 추가, UIFont 확장 타입 메서드 구현, 컬러 에셋 추가|
|[#9 MomentTitleInputViewController 기능 구현](https://github.com/thinkySide/poporazzi/pull/9)|Input&Output 패턴 적용, MomentTitleViewController 내 로직 구현, UserDefaults 로직 구현|
|[#11 MomentRecord 화면 구현](https://github.com/thinkySide/poporazzi/pull/11)|MomentRecordView 구현, NavigationBar 및 NavigationButton UIComponent 구현, UICollectionViewCompositionalLayout를 이용한 CollectionView 구성|
|[#13 PhotoKit을 이용한 사진 반환 객체 구현](https://github.com/thinkySide/poporazzi/pull/13)|PhotoKitService 구현, 사진 불러오기 및 앨범 저장 함수 구현|
|[#15 전체 Flow 연결](https://github.com/thinkySide/poporazzi/pull/15)|전체 Flow 연결, 기록 종료 Alert 추가, 화면 진입 시(SceneDelegate) 앨범 리스트 업데이트|
|[#17 1.0.0 심사 제출](https://github.com/thinkySide/poporazzi/pull/17)|지원 OS iOS로 한정, 앱 로고 및 스크린샷 설정, 앱스토어 심사 설정|

#### v1.1.0 ~ v1.1.1 / 25.04.16 ~ 25.05.01
> MVP는 기능이 너무 많이빠져있었다,,! 기록을 편집할 수 있는 기능 추가 및 약간의 디자인 업데이트(개구쟁이 파파라치 컨셉?)

|PR 제목|주요 구현 내용|
|:--|:--|
|[#24 Input & Output 패턴 리팩토링](https://github.com/thinkySide/poporazzi/pull/24)|Input & Output 패턴 리팩토링 및 컨벤션 확립, AlertAction 패턴 구현|
|[#26 전체 UI 업데이트](https://github.com/thinkySide/poporazzi/pull/26)|둘기마요 폰트 적용, 디자인 일괄 업데이트, SFSymbol 관리 열거형 구현|
|[#28 MomentRecordView 이벤트 연결](https://github.com/thinkySide/poporazzi/pull/28)|더보기 Menu 구현, Media 엔티티 업데이트, 기록 Cell MediaType 별 UI 구현|
|[#30 MomentEditView 기능 구현을 위한 세팅](https://github.com/thinkySide/poporazzi/pull/30)|MomentEdit 화면 구현, SFSymbol 편의생성자 구현|
|[#32 MomentEdit 기능 구현](https://github.com/thinkySide/poporazzi/pull/32)|앨범 이름 및 시작 날짜 변경 기능 구현|
|[#35 전체 ViewModel 리팩토링 및 Coordinator 도입](https://github.com/thinkySide/poporazzi/pull/35)|전체 ViewModel 리팩토링, Coordinator 패턴 도입|
|[#37 UX/UI 디테일 추가](https://github.com/thinkySide/poporazzi/pull/37)|앱 아이콘 업데이트, 컬러 보드 업데이트, DatePicker 수정|
|[#39 1.1.0 배포](https://github.com/thinkySide/poporazzi/pull/39)|1.1.0 배포 완료|
|[#41 기록한 사진이 없을 때 종료 케이스 추가](https://github.com/thinkySide/poporazzi/pull/41)|사진이 비어있을 때 화면이 넘어가지 않던 버그 수정|
|[#44 1.1.1 배포](https://github.com/thinkySide/poporazzi/pull/44)|1.1.1 배포 완료|

#### v1.2.0 ~ v1.2.1 / 25.05.01 ~ 25.05.04
> 이펙트를 크게 낼 수 있는 기능 위주로 구현해보자! 우선은 Live Activity를 이용해 지속적인 경험을 할 수 있게 도와주자~

|PR 제목|주요 구현 내용|
|:--|:--|
|[#45 기록 Live Activity 기능 구현](https://github.com/thinkySide/poporazzi/pull/45)|기본 LiveActivity 기능 구현, Coordinator 순환 참조 문제 해결, 디버깅을 위한 Log 구조체 생성, 앱 Light 모드 고정|
|[#47 DI Container 구현](https://github.com/thinkySide/poporazzi/pull/47)|DI Container, Dependency 매크로 구현 및 ViewModel 내 주입|
|[#49 사진 라이브러리 변경에 따른 업데이트 기능 추가](https://github.com/thinkySide/poporazzi/pull/49)|PHPhotoLibraryChangeObserver 프로토콜을 이용한 라이브러리 변화 감지 및 UI + LiveActivity 업데이트 기능 추가|
|[#51 App 업데이트 Alert 기능 구현](https://github.com/thinkySide/poporazzi/pull/51)|VersionService 구현, 최신 버전 아닐 시 AppStore 이동 Alert 추가|
|[#53 1.2.0 배포](https://github.com/thinkySide/poporazzi/pull/53)|1.2.0 배포 완료|
|[#55 1.2.1 Minor 업데이트](https://github.com/thinkySide/poporazzi/pull/55)|Live Activity 업데이트, AppStore 업데이트 Alert 로직 업데이트|

#### v1.3.0 ~ v1.3.1 / 25.05.04 ~ 25.05.08
> 앨범 기록 중 특정 사진을 제외하거나 삭제하는 기능이 필요하다는 정보를 얻었다. 바로 추가해보자!

|PR 제목|주요 구현 내용|
|:--|:--|
|[#57 기록 선택 모드 기능 구현](https://github.com/thinkySide/poporazzi/pull/57)|앨범에서 제외 및 삭제 기능 구현, ToolBar 및 LoadingIndicator UI Component 구현, ActionSheet Model 구현|
|[#59 ExcludeRecord 화면 구현](https://github.com/thinkySide/poporazzi/pull/59)|ExcludeRecord UI 구현|
|[#61 ExcludeRecord 기능 구현](https://github.com/thinkySide/poporazzi/pull/61)|제외된 화면 내 기록 복구 및 기록 삭제 기능 구현|
|[#63 PhotoKit 및 RecordCollectionView 사진 로드 속도 개선하기](https://github.com/thinkySide/poporazzi/pull/63)|RecordCollectionView 이미지 로드 속도 개선(페이지네이션), PhotoKitService 병렬 처리 구현, UICollectionViewDiffableDataSource 도입|
|[#65 1.3.0 배포](https://github.com/thinkySide/poporazzi/pull/65)|ExcludeView CollectionView 업데이트, 사진 앱 앨범 DeepLink 구현, 전반적인 순환참조 문제 해결|
|[#67 유닛 테스트 환경 세팅 및 작성](https://github.com/thinkySide/poporazzi/pull/67)|Unit Test Target 추가, Live Activity 및 PhotoKit Service 인터페이스 구현 및 Mock 객체 생성, XCTest를 활용한 테스트 코드 작성|
|[#69 앨범 저장 오류 해결](https://github.com/thinkySide/poporazzi/pull/69)|동일한 이름의 앨범 생성 시, 저장 후 덮어씌워지는 문제 해결, 제외된 기록이 추가되었음에도 종료 시 반영되지 않는 문제 해결|

#### v1.4.0 ~ 1.4.2 / 25.05.09 ~
> MVP 개발 때 부터 생각했던 일자별로 앨범을 나누는 기능이 기술적으로 가능함을 확인했다. 이제 하루 이상 기록하게 되면 일차별로 나눠보자!

|PR 제목|주요 구현 내용|
|:--|:--|
|[#73 RecordView UI 업데이트](https://github.com/thinkySide/poporazzi/pull/73)|UICompositionalLayout, DiffableDataSource에 맞춘 Header 추가|
|[#75 FinishModal 화면 구현](https://github.com/thinkySide/poporazzi/pull/75)|FinishModal 화면 구현 및 네비게이션 연결, RadioButton 및 CancelButton UIComponent 구현|
|[#77 앨범 저장 옵션 설정 및 저장 기능 구현](https://github.com/thinkySide/poporazzi/pull/77)|하나로, 일차별 앨범 저장 기능 구현|
|[#79 RecordView 일차 별 분리 기능 구현](https://github.com/thinkySide/poporazzi/pull/79)|Media 배열 날짜 별 Section 분리 로직 구현|
|[#81 1.4.0 업데이트 전 QA](https://github.com/thinkySide/poporazzi/pull/81)|1.4.0 배포 및 일부 UI 개선|
|[#83 일차별 앨범 저장 기능 동시성 처리](https://github.com/thinkySide/poporazzi/pull/83)|일차별 앨범 저장 시 중복 이벤트 발생 및 속도 저하 문제 해결|
|[#85 앱스토어 리뷰 Alert 기능 구현](https://github.com/thinkySide/poporazzi/pull/85)|기록 종료 시 StoreKit을 이용한 앱스토어 리뷰 Alert 출력 기능 구현|
|[#87 저장 없이 기록 종료 기능 추가](https://github.com/thinkySide/poporazzi/pull/87)|앨범을 생성하지 않고 기록 종료 기능 추가|
|[#89 스크린샷 제외 기능 구현](https://github.com/thinkySide/poporazzi/pull/89)|PHMediaSubtypes를 이용한 스크린샷 제외 기능 구현| 
|[#91 1.4.2 배포 전 QA](https://github.com/thinkySide/poporazzi/pull/91)|TitleInputView UI 업데이트|
