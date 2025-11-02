# 기여 가이드

Dialogym-docs 레포지토리에 기여해주셔서 감사합니다. 이 문서는 문서 작성 및 관리 규칙을 안내합니다.

## 문서 작성 규칙

### 파일명 컨벤션

- 소문자와 하이픈 사용: `feature-specification.md`
- 날짜 포함 시 YYYY-MM-DD 형식: `2024-11-02-sprint-planning.md`
- 한글 파일명도 허용하되 일관성 유지

### 마크다운 스타일

- 제목은 `#`으로 시작 (H1은 문서당 하나만)
- 코드 블록은 언어 지정: ```javascript
- 목록은 `-` 사용
- 링크는 상대 경로 사용: `[문서](docs/design/architecture/example.md)`

## 브랜치 전략

- `main`: 최신 안정 버전
- `feature/*`: 새로운 문서 작성
- `update/*`: 기존 문서 수정
- `fix/*`: 오타 및 오류 수정

## 커밋 메시지 규칙

```
<타입>: <제목>

<본문 (선택)>
```

### 타입
- `docs`: 문서 추가/수정
- `fix`: 오타 및 오류 수정
- `refactor`: 문서 구조 변경
- `chore`: 기타 작업

### 예시
```
docs: API 설계 문서 추가

RESTful API 엔드포인트 설계 문서 작성
```

## Pull Request 프로세스

1. 작업 브랜치 생성
2. 문서 작성/수정
3. 커밋 및 푸시
4. PR 생성 (템플릿 활용)
5. 최소 1명의 리뷰어 승인 필요
6. 승인 후 `main`에 머지

## 디렉토리별 문서 배치 가이드

### `docs/requirements/`
프로젝트 요구사항, 기능 명세, 문제 분석 등 초기 기획 문서

### `docs/design/`
시스템 설계, API 설계, DB 스키마, UI/UX 디자인 등 설계 문서

### `docs/decisions/`
기술 스택 선정, 아키텍처 결정 등 의사결정 기록 (ADR 형식 권장)

### `docs/processes/`
개발, 배포, 테스트, 협업 프로세스 가이드

### `docs/meetings/`
회의록, 스프린트 계획/회고, 진행 상황 로그

### `docs/troubleshooting/`
개발 중 발생한 문제와 해결 방법 기록

### `docs/reports/`
주간/월간 보고서

### `docs/team/`
팀 구성, 역할, 기술 스택 등 팀 관련 정보

### `docs/archive/`
더 이상 사용하지 않는 문서 보관

## 템플릿 사용

새로운 문서 작성 시 해당 템플릿을 활용하세요:

- 회의록: `docs/meetings/meeting-note-template.md`
- 트러블슈팅: `docs/troubleshooting/troubleshooting-template.md`
- 일반 문서: `docs/processes/document-template.md`

## 문서 작성 팁

- **명확성**: 누구나 이해할 수 있도록 명확하게 작성
- **간결성**: 불필요한 내용은 제거
- **최신성**: 변경사항 발생 시 즉시 업데이트
- **참조**: 관련 문서는 링크로 연결
- **시각화**: 다이어그램, 표 등을 활용하여 이해도 향상

## 질문 및 논의

문서 작성 관련 질문이나 제안사항은 이슈를 생성하거나 팀 채널에서 논의해주세요.
