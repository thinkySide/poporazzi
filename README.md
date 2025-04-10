# poporazzi 포포라치
> 여행과 함께 사진을 정리하는 것에는 너무 많은 것이 나입니다! (개발자 이야기입니다.) 그냥 괜히 쉽게 사진 정리하자,,,!

|상태|앱스토어 배포 완료 및 업데이트 진행 중(v1.0.0)|
|:--|:--|
|기술 스택|UIKit, RxSwift, FlexLayout, PinLayout, PhotoKit|
|앱스토어|정보 업데이트 예정|
|이메일 문의|eunlyuing@gmail.com|

### 완전 쉬운 포포라치 3️⃣단계 이용법
1. 여행 전 기록 시작하기 버튼을 누르세요. 🎬
2. 내 맘대로 여행을 즐기며 사진을 찍으세요. 📸
3. 여행 다녀온 후 종료 버튼 마지막 앨범으로 쏙 저장하기! 🌃

![Frame 2](https://github.com/user-attachments/assets/0e70e01e-e351-4205-9925-00ac5f57a2fa)

### 개발 타임라인
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
