# 마음일기 (Quiet Diary)

학교밖 청소년이 AI와 대화하듯 하루를 풀어내면, 일기로 자동 변환되어 기록되고, 위험 신호 감지 시 청소년이 직접 고른 신뢰 어른과 안전하게 연결되는 모바일 앱.

## 기술 스택

- **프레임워크**: Flutter (Dart)
- **상태 관리**: Riverpod
- **폰트**: Google Fonts (Noto Sans KR)
- **아이콘**: Lucide Icons

## 프로젝트 구조

```
lib/
├── main.dart
├── core/
│   ├── models/         # 데이터 모델
│   ├── providers/      # Riverpod 상태 관리
│   ├── theme/          # 색상, 테마
│   └── utils/          # 공통 유틸리티
└── presentation/
    ├── layouts/        # 앱 전체 레이아웃
    ├── screens/        # 화면 단위 위젯
    └── widgets/        # 공통 위젯
```

## 화면 구성

| 파일 | 역할 |
|---|---|
| `home_screen.dart` | 대화 시작 / 입력 진입점 |
| `voice_chat_screen.dart` | 음성 대화 (모드 A) |
| `text_chat_screen.dart` | 텍스트 대화 (모드 B) |
| `diary_preview_screen.dart` | AI 일기 변환 / 저장 선택 |
| `diary_list_screen.dart` | 일기 캘린더 + 목록 |
| `diary_detail_screen.dart` | 일기 상세 / 수정 |
| `trusted_persons_screen.dart` | 신뢰 인물 목록 |
| `trusted_person_form_screen.dart` | 신뢰 인물 추가 / 수정 |

## 주요 기능

- **F1** 음성·텍스트 대화 → AI 자동 일기 변환 (직접 쓰기 지원)
- **F3** 신뢰 인물 페어링 시스템 (옵션)
- **F4** 위기 자원 1탭 연결 (1393, 1388, 1577-0199)
