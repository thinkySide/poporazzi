# 🥷📸 poporazzi 포포라치
> 여행 다녀와서 사진 정리하는게 너무 귀찮은 나! (개발자 본인 이야기입니다.) 이젠 좀 쉽게 사진 정리하자,,,!

|상태|앱스토어 배포 완료 및 업데이트 진행 중(v1.2.0)|
|:--|:--|
|기술 스택|UIKit, RxSwift, FlexLayout, PinLayout, PhotoKit|
|Link|[AppStore](https://apps.apple.com/kr/app/%ED%8F%AC%ED%8F%AC%EB%9D%BC%EC%B9%98/id6744402068), [Figma](https://www.figma.com/design/4uudfkvUr18HbnBhyKSTro/%ED%8F%AC%ED%8F%AC%EB%9D%BC%EC%B9%98?node-id=57-364&p=f&t=5ZyurDKbkj51pwCl-11)|
|이메일 문의|eunlyuing@gmail.com|

### 완전 쉬운 포포라치 3️⃣단계 이용법
1. 여행 전 기록 시작하기 버튼 꾹 눌러놓기.
2. 내맘대로 여행 즐기며 마음껏 사진 찍기.
3. 여행 다녀온 후 종료 버튼 눌러 앨범으로 쏙 저장하기!

![Frame 2](https://github.com/user-attachments/assets/cec1dfdb-8582-4825-ac49-2421dbeb9e28)

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

#### v1.2.0 / 25.05.01 ~ 진행중
> 이펙트를 크게 낼 수 있는 기능 위주로 구현해보자! 우선은 Live Activity를 이용해 지속적인 경험을 할 수 있게 도와주자~

|PR 제목|주요 구현 내용|
|:--|:--|
|[#45 기록 Live Activity 기능 구현](https://github.com/thinkySide/poporazzi/pull/45)|기본 LiveActivity 기능 구현, Coordinator 순환 참조 문제 해결, 디버깅을 위한 Log 구조체 생성, 앱 Light 모드 고정|
|[#47 DI Container 구현](https://github.com/thinkySide/poporazzi/pull/47)|DI Container, Dependency 매크로 구현 및 ViewModel 내 주입|
|[#49 사진 라이브러리 변경에 따른 업데이트 기능 추가](https://github.com/thinkySide/poporazzi/pull/49)|PHPhotoLibraryChangeObserver 프로토콜을 이용한 라이브러리 변화 감지 및 UI + LiveActivity 업데이트 기능 추가|
|[#51 App 업데이트 Alert 기능 구현](https://github.com/thinkySide/poporazzi/pull/51)|VersionService 구현, 최신 버전 아닐 시 AppStore 이동 Alert 추가|
|[#51 App 업데이트 Alert 기능 구현](https://github.com/thinkySide/poporazzi/pull/51)|VersionService 구현, 최신 버전 아닐 시 AppStore 이동 Alert 추가|
|[#53 1.2.0 배포](https://github.com/thinkySide/poporazzi/pull/53)|1.2.0 배포 완료|
